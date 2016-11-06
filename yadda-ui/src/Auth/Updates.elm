module Auth.Updates exposing (..)

import Auth.Messages exposing (Msg(..))
import Auth.Model exposing (Authentication)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
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

update : Msg -> Authentication -> String -> (Authentication, Cmd Msg)
update message auth baseUrl =
  case message of
    AuthError error ->
      ( { auth | errorMsg = (toString error) } |> Debug.log "Error", Cmd.none )
    GetTokenSuccess newToken ->
      ( { auth | token = newToken, password = "", errorMsg = "" }, Cmd.none )
    Login ->
      ( auth, authUserCmd auth baseUrl authUrl )
    Logout ->
      ( auth, Cmd.none )
    SetPassword password ->
      ( { auth | password = password }, Cmd.none )
    SetUsername username ->
      ( { auth | username = username }, Cmd.none )
