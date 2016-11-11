module Auth.Updates exposing (..)

import Auth.Messages exposing (Msg(..))
import Auth.Model exposing (Authentication, JwtPayload)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Jwt exposing (..)
import Task exposing (Task)
import Time

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
        ("exp" := Decode.float)

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

authenticatedCmd : Authentication -> Cmd Msg
authenticatedCmd model =
  Task.perform assertNeverHandler (Authenticated << checkExpiry model) Time.now

checkExpiry : Authentication -> Float -> Bool
checkExpiry model now =
  let
    seconds = now / 1000
  in
    seconds < model.payload.expiry |> Debug.log ((toString seconds) ++ " " ++ (toString model.payload.expiry))

assertNeverHandler : a -> b
assertNeverHandler =
    (\_ -> Debug.crash "This should never happen")

logout : Authentication -> ( Authentication, Cmd Msg )
logout model =
  update Logout model ""

update : Msg -> Authentication -> String -> (Authentication, Cmd Msg)
update message auth baseUrl =
  case message of
    Authenticated authenticated ->
      ( { auth | authenticated = authenticated }, Cmd.none )
    AuthError error ->
      ( { auth | username = "", password = "", token = "", errorMsg = (toString error) }, Cmd.none )
    GetTokenSuccess newToken ->
      ( { auth | token = newToken, password = "", errorMsg = "" }, decodeTokenCmd newToken )
    DecodeError error ->
      ( { auth | errorMsg = (toString error) }, Cmd.none )
    DecodeTokenSuccess payload ->
      let
        newModel = { auth | payload = payload }
      in
        ( newModel, authenticatedCmd newModel )
    Login ->
      ( auth, authUserCmd auth baseUrl authUrl )
    Logout ->
      ( Auth.Model.new, Cmd.none )
    SetPassword password ->
      ( { auth | password = password }, Cmd.none )
    SetUsername username ->
      ( { auth | username = username }, Cmd.none )
