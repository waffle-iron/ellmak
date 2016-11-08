module Notify.Updates exposing (..)

import Notify.Messages exposing (..)
import Notify.Model exposing (..)

show : Notification -> (Notification, Cmd Msg)
show model =
  update Show model

hide : Notification -> (Notification, Cmd Msg)
hide model =
  update Hide model

update : Msg -> Notification -> (Notification, Cmd Msg)
update message notification =
  case message of
    Show ->
      ( { notification | hidden = False }, Cmd.none )
    Hide ->
      ( { notification | hidden = True }, Cmd.none )
