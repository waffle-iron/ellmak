module Notify.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Notify.Messages exposing (..)
import Notify.Model exposing (Notification)


baseClass : String
baseClass =
    "notification alert "


genClass : Notification -> String
genClass model =
    case ( model.hidden, model.level ) of
        ( True, "success" ) ->
            baseClass ++ "alert-success"

        ( True, "info" ) ->
            baseClass ++ "alert-info"

        ( True, "warning" ) ->
            baseClass ++ "alert-warning"

        ( True, "danger" ) ->
            baseClass ++ "alert-danger"

        ( True, _ ) ->
            baseClass ++ "alert-warning"

        ( False, "success" ) ->
            baseClass ++ "show alert-success"

        ( False, "info" ) ->
            baseClass ++ "show alert-info"

        ( False, "warning" ) ->
            baseClass ++ "show alert-warning"

        ( False, "danger" ) ->
            baseClass ++ "show alert-danger"

        ( False, _ ) ->
            baseClass ++ "show alert-danger"


view : Notification -> Html Msg
view model =
    div [ class (genClass model) ]
        [ strong [] [ text model.message ]
        ]
