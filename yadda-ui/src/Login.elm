module Login exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

type alias Model =
  { username: String
  , password: String
  , token: String
  , errorMsg: String
  }

initialModel : Model
initialModel =
  { username = ""
  , password = ""
  , token = ""
  , errorMsg = ""
  }

type Msg
  = Login
  | Logout
  | SetPassword String
  | SetUsername String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    --GetTokenSuccess newToken ->
    --  ( { model | token = newToken, password = "", errorMsg = "" } |> Debug.log "got new token", Cmd.none )
    Login ->
      -- TODO: Update the command
      ( model, Cmd.none )
    Logout ->
      ( initialModel, Cmd.none )
    SetPassword password ->
      ( { model | password = password }, Cmd.none )
    SetUsername username ->
      ( { model | username = username } |> Debug.log model.username, Cmd.none )

view : Model -> Html Msg
view model =
  let
    -- If there is an error on authentication, show the error alert
    showError : String
    showError =
      if String.isEmpty model.errorMsg then "hidden" else ""
  in
    div [ id "form" ] [
      h2 [ class "text-center" ] [ text "Login"]
      , div [ class showError ] [
        div [ class "alert alert-danger" ] [ text model.errorMsg ]
      ]
      , div [ class "form-group row" ] [
        div [ class "col-md-offset-2 col-md-8" ] [
          label [ for "username" ] [ text "Username: " ]
          , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
        ]
      ]
      , div [ class "form-group row"] [
        div [ class "col-md-offset-2 col-md-8" ] [
          label [ for "password" ] [text "Password: " ]
          , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
        ]
      ]
      , div [ class "text-center"] [
        button [ class "btn btn-primary", onClick Login ] [ text "Login" ]
      ]
    ]
