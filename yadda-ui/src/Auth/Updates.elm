module Auth.Updates exposing (..)

import Auth.Messages exposing (Msg(..))
import Auth.Model exposing (Authentication, JwtError(..), JwtPayload)
import Base64
import Http
import Json.Decode exposing (..)
import Json.Encode exposing (..)
import Task exposing (Task)
import Time


authUrl : String
authUrl =
    "/login"


unurl : String -> String
unurl =
    let
        fix c =
            case c of
                '-' ->
                    '+'

                '_' ->
                    '/'

                c ->
                    c
    in
        String.map fix


fixlength : String -> Result JwtError String
fixlength s =
    case String.length s % 4 of
        0 ->
            Result.Ok s

        2 ->
            Result.Ok <| String.concat [ s, "==" ]

        3 ->
            Result.Ok <| String.concat [ s, "=" ]

        _ ->
            Result.Err <| TokenProcessingError "Wrong length"


decodeToken : Decoder a -> String -> Result JwtError a
decodeToken dec s =
    let
        f1 =
            String.split "." <| unurl s

        f2 =
            List.map fixlength f1
    in
        case f2 of
            _ :: (Result.Err e) :: _ :: [] ->
                Result.Err e

            _ :: (Result.Ok encBody) :: _ :: [] ->
                case Base64.decode encBody of
                    Result.Ok body ->
                        case Json.Decode.decodeString dec body of
                            Result.Ok x ->
                                Result.Ok x

                            Result.Err e ->
                                Result.Err (TokenDecodeError e)

                    Result.Err e ->
                        Result.Err (TokenProcessingError e)

            _ ->
                Result.Err <| TokenProcessingError "Token has invalid shape"


userEncoder : Authentication -> Json.Encode.Value
userEncoder model =
    Json.Encode.object
        [ ( "username", Json.Encode.string model.username )
        , ( "password", Json.Encode.string model.password )
        ]


tokenDecoder : Decoder String
tokenDecoder =
    field "id_token" Json.Decode.string


tokenPayloadDecoder : Decoder JwtPayload
tokenPayloadDecoder =
    Json.Decode.map4 JwtPayload
        (field "username" Json.Decode.string)
        (field "name" Json.Decode.string)
        (field "iat" Json.Decode.int)
        (field "exp" Json.Decode.float)


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
        Http.send AuthUserResult request


fromDecodeResult : Result JwtError JwtPayload -> Task JwtError JwtPayload
fromDecodeResult result =
    case result of
        Ok payload ->
            Task.succeed payload

        Err error ->
            Task.fail error


decodeTokenCmd : String -> Cmd Msg
decodeTokenCmd token =
    Task.attempt DecodeResult (fromDecodeResult <| decodeToken tokenPayloadDecoder token)


authenticatedCmd : Authentication -> Cmd Msg
authenticatedCmd model =
    Task.perform (Authenticated << checkExpiry model) Time.now


checkExpiry : Authentication -> Float -> Bool
checkExpiry model now =
    let
        seconds =
            now / 1000
    in
        seconds < model.payload.expiry


assertNeverHandler : a -> b
assertNeverHandler =
    (\_ -> Debug.crash "This should never happen")


logout : Authentication -> ( Authentication, Cmd Msg )
logout model =
    update Logout model ""


update : Msg -> Authentication -> String -> ( Authentication, Cmd Msg )
update message auth baseUrl =
    case message of
        Authenticated authenticated ->
            ( { auth | authenticated = authenticated }, Cmd.none )

        AuthUserResult result ->
            case result of
                Ok newToken ->
                    ( { auth | token = newToken, password = "", errorMsg = "" }, decodeTokenCmd newToken )

                Err error ->
                    ( { auth | username = "", password = "", token = "", errorMsg = (toString error) }, Cmd.none )

        DecodeResult result ->
            case result of
                Ok payload ->
                    let
                        newModel =
                            { auth | payload = payload }
                    in
                        ( newModel, authenticatedCmd newModel )

                Err error ->
                    ( { auth | errorMsg = (toString error) }, Cmd.none )

        Login ->
            ( auth, authUser auth baseUrl authUrl )

        Logout ->
            ( Auth.Model.new, Cmd.none )

        SetPassword password ->
            ( { auth | password = password }, Cmd.none )

        SetUsername username ->
            ( { auth | username = username }, Cmd.none )
