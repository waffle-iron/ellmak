module Auth.Updates exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (Authentication, AuthError(..), JwtPayload)
import Http
import Json.Decode exposing (..)
import Json.Encode exposing (..)
import Jwt exposing (decodeToken, JwtError)
import Task exposing (Task)
import Time


authUrl : String
authUrl =
    "/auth"


userEncoder : Authentication -> Json.Encode.Value
userEncoder model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]


tokenDecoder : Decoder String
tokenDecoder =
    field "id_token" Json.Decode.string


authUser : Authentication -> String -> Cmd Msg
authUser model baseUrl =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = (baseUrl ++ authUrl)
                , body = Http.jsonBody <| userEncoder model
                , expect = Http.expectJson tokenDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send (ForSelf << AuthUserResult) request


fromDecodeResult : Result JwtError JwtPayload -> Task JwtError JwtPayload
fromDecodeResult result =
    case result of
        Ok payload ->
            Task.succeed payload

        Err error ->
            Task.fail error


tokenPayloadDecoder : Decoder JwtPayload
tokenPayloadDecoder =
    Json.Decode.map4 JwtPayload
        (field "username" Json.Decode.string)
        (field "name" Json.Decode.string)
        (field "iat" Json.Decode.int)
        (field "exp" Json.Decode.float)


decodeTokenCmd : String -> Cmd Msg
decodeTokenCmd token =
    Task.attempt (ForSelf << DecodeResult) (fromDecodeResult <| decodeToken tokenPayloadDecoder token)


authenticated : Authentication -> Cmd Msg
authenticated model =
    Task.perform (ForSelf << Authenticated << checkExpiry model) Time.now


checkExpiry : Authentication -> Float -> Bool
checkExpiry model now =
    let
        seconds =
            floor (now / 1000)
    in
        toFloat seconds < model.payload.expiry


logout : Authentication -> ( Authentication, Cmd Msg )
logout model =
    update Logout model ""


generateParentMsg : ExternalMsg -> Cmd Msg
generateParentMsg externalMsg =
    Task.perform ForParent (Task.succeed externalMsg)


authError : Authentication -> AuthError -> ( Authentication, Cmd Msg )
authError auth error =
    ( { auth | username = "", password = "", token = "" }, generateParentMsg (AuthenticationError error) )


refreshEncoder : Authentication -> Json.Encode.Value
refreshEncoder model =
    Json.Encode.object
        [ ( "token", Json.Encode.string model.token )
        , ( "username", Json.Encode.string model.username )
        ]


refreshToken : Authentication -> String -> Cmd Msg
refreshToken model baseUrl =
    let
        request =
            Http.request
                { method = "PUT"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.token)) ]
                , url = (baseUrl ++ authUrl)
                , body = Http.jsonBody <| refreshEncoder model
                , expect = Http.expectJson tokenDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send (ForSelf << RefreshTokenResult) request


update : InternalMsg -> Authentication -> String -> ( Authentication, Cmd Msg )
update message auth baseUrl =
    case message of
        Authenticated authenticated ->
            let
                nextCmd =
                    case authenticated of
                        True ->
                            generateParentMsg AuthenticationSuccess

                        False ->
                            Cmd.none
            in
                ( { auth | authenticated = authenticated }, nextCmd )

        AuthUserResult result ->
            case result of
                Ok newToken ->
                    ( { auth | token = newToken, password = "" }, decodeTokenCmd newToken )

                Err error ->
                    authError auth (HttpError error)

        DecodeResult result ->
            case result of
                Ok payload ->
                    let
                        newModel =
                            { auth | payload = payload }
                    in
                        ( newModel, authenticated newModel )

                Err error ->
                    authError auth (TokenError error)

        Login ->
            ( auth, authUser auth baseUrl )

        Logout ->
            ( Auth.Model.defaultAuthentication, Cmd.none )

        SetPassword password ->
            ( { auth | password = password }, Cmd.none )

        SetUsername username ->
            ( { auth | username = username }, Cmd.none )

        RefreshTokenResult result ->
            case result of
                Ok newToken ->
                    let
                        newAuth =
                            { auth | token = newToken }
                    in
                        ( newAuth, decodeTokenCmd newToken )

                Err err ->
                    ( auth, Cmd.none )

        RefreshRequest time ->
            ( auth, refreshToken auth baseUrl )
