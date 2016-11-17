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
    "/login"


userEncoder : Authentication -> Json.Encode.Value
userEncoder model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]


tokenDecoder : Decoder String
tokenDecoder =
    field "id_token" Json.Decode.string


authUser : Authentication -> String -> String -> Cmd Msg
authUser model baseUrl apiUrl =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = (baseUrl ++ apiUrl)
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
            now / 1000
    in
        seconds < model.payload.expiry


logout : Authentication -> ( Authentication, Cmd Msg )
logout model =
    update Logout model ""


generateParentMsg : ExternalMsg -> Cmd Msg
generateParentMsg externalMsg =
    Task.perform ForParent (Task.succeed externalMsg)


authError : Authentication -> AuthError -> ( Authentication, Cmd Msg )
authError auth error =
    ( { auth | username = "", password = "", token = "" }, generateParentMsg (AuthenticationError error) )


update : InternalMsg -> Authentication -> String -> ( Authentication, Cmd Msg )
update message auth baseUrl =
    case message of
        Authenticated authenticated ->
            ( { auth | authenticated = authenticated }, Cmd.none )

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
            ( auth, authUser auth baseUrl authUrl )

        Logout ->
            ( Auth.Model.defaultAuthentication, Cmd.none )

        SetPassword password ->
            ( { auth | password = password }, Cmd.none )

        SetUsername username ->
            ( { auth | username = username }, Cmd.none )
