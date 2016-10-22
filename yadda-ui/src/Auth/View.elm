module Auth.View exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (Authentication)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import String

view : Authentication -> Html Msg
view auth =
  div [ id "form" ] [
    header auth
    , div [ class "form-group row" ] [
      div [ class "col-md-offset-2 col-md-8" ] [
        label [ for "username" ] [ text "Username: " ]
        , input [ id "username", type' "text", class "form-control", Html.Attributes.value auth.username, onInput SetUsername ] []
      ]
    ]
    , div [ class "form-group row"] [
      div [ class "col-md-offset-2 col-md-8" ] [
        label [ for "password" ] [text "Password: " ]
        , input [ id "password", type' "password", class "form-control", Html.Attributes.value auth.password, onInput SetPassword ] []
      ]
    ]
    , div [ class "text-center"] [
      button [ class "btn btn-primary", onClick Login ] [ text "Login" ]
    ]
  ]

header : Authentication -> Html Msg
header auth =
    let
      -- If there is an error on authentication, show the error alert
      showError : String
      showError =
        if String.isEmpty auth.errorMsg then "hidden" else ""
    in
      div [] [
        h2 [ class "text-center" ] [ text "Login"]
        , div [ class showError ] [
          div [ class "alert alert-danger" ] [ text auth.errorMsg ]
        ]
      ]
