module Notify.Updates exposing (..)

import Notify.Messages exposing (..)
import Notify.Model exposing (..)
import Process exposing (..)
import Task exposing (..)
import Time exposing (..)


show : Notification -> ( Notification, Cmd Msg )
show model =
    update Show model


hideCmd : Cmd Msg
hideCmd =
    Task.perform (\_ -> Hide) <| Process.sleep (2.5 * Time.second)


resetCmd : Cmd Msg
resetCmd =
    Task.perform (\_ -> Reset) <| Process.sleep (5 * Time.second)


update : Msg -> Notification -> ( Notification, Cmd Msg )
update message notification =
    case message of
        Show ->
            (!) { notification | hidden = False } [ hideCmd, resetCmd ]

        Hide ->
            ( { notification | hidden = True }, Cmd.none )

        Reset ->
            ( Notify.Model.new, Cmd.none )
