module Auth.Updates exposing (..)

import Auth.Messages exposing (Msg(..))
import Auth.Model exposing (Authentication)

update : Msg -> Authentication -> (Authentication, Cmd Msg)
update message auth =
  case message of
    Login ->
      ( auth |> Debug.log "Login", Cmd.none )
    Logout ->
      ( auth, Cmd.none )
    SetPassword password ->
      ( { auth | password = password }, Cmd.none )
    SetUsername username ->
      ( { auth | username = username }, Cmd.none )
