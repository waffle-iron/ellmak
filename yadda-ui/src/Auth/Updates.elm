module Auth.Updates exposing (..)

import Auth.Messages exposing (Msg(..))
import Auth.Model exposing (Authentication, JwtPayload)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Jwt exposing (..)
import Task exposing (Task)

authUrl : String
authUrl =
  "/login"

userEncoder : Authentication -> Encode.Value
userEncoder model =
  Encode.object
    [ ("username", Encode.string model.username)
    , ("password", Encode.string model.password)
    ]

tokenDecoder : Decoder String
tokenDecoder =
  "id_token" := Decode.string

tokenPayloadDecoder : Decoder JwtPayload
tokenPayloadDecoder =
    Decode.object4 JwtPayload
        ("username" := Decode.string)
        ("name" := Decode.string)
        ("iat" := Decode.int)
        ("exp" := Decode.int)

authUser : Authentication -> String -> String -> Task Http.Error String
authUser model baseUrl apiUrl =
  { verb = "POST"
  , headers = [ ("Content-Type", "application/json" ) ]
  , url = baseUrl ++ apiUrl
  , body = Http.string <| Encode.encode 0 <| userEncoder model
  }
  |> Http.send Http.defaultSettings
  |> Http.fromJson tokenDecoder

authUserCmd : Authentication -> String -> String -> Cmd Msg
authUserCmd model baseUrl apiUrl =
  Task.perform AuthError GetTokenSuccess <| authUser model baseUrl apiUrl

decodeTokenCmd : String -> Cmd Msg
decodeTokenCmd token =
  Task.perform DecodeError DecodeTokenSuccess
    <| Task.fromResult
    <| decodeToken tokenPayloadDecoder token

update : Msg -> Authentication -> String -> (Authentication, Cmd Msg)
update message auth baseUrl =
  case message of
    AuthError error ->
      ( { auth | errorMsg = (toString error) }, Cmd.none )
    GetTokenSuccess newToken ->
      ( { auth | token = newToken, password = "", errorMsg = "" }, decodeTokenCmd newToken )
    DecodeError error ->
      ( { auth | errorMsg = (toString error) }, Cmd.none )
    DecodeTokenSuccess payload ->
      ( { auth | payload = payload }, Cmd.none )
    Login ->
      ( auth, authUserCmd auth baseUrl authUrl )
    Logout ->
      ( auth, Cmd.none )
    SetPassword password ->
      ( { auth | password = password }, Cmd.none )
    SetUsername username ->
      ( { auth | username = username }, Cmd.none )
