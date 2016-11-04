module Main exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (..)
import Auth.Updates exposing (..)
import Auth.View exposing (..)
import Html exposing (..)
import Html.App exposing (map, program)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Ports exposing (storeModel, removeModel)
import String exposing (..)

main : Program (Maybe Model)
main =
  Html.App.programWithFlags
    { init = init
    , update = update
    , subscriptions = \_ -> Sub.none
    , view = view
    }

init : Maybe Model -> (Model, Cmd Msg)
init model =
  case model of
    Just model ->
      (model, Cmd.none)
    Nothing ->
      (Model Auth.Model.new "", Cmd.none)

-- randomQuoteUrl : String
-- randomQuoteUrl =
--   api ++ "/quotes"
--
-- protectedQuoteUrl : String
-- protectedQuoteUrl =
--   api ++ "/protected/quotes"
--
-- registerUrl : String
-- registerUrl =
--   api ++ "/users"
--
-- loginUrl : String
-- loginUrl =
--   api ++ "sessions/create"
--
-- fetchRandomQuote : Platform.Task Http.Error String
-- fetchRandomQuote =
--   Http.getString randomQuoteUrl
--
-- fetchRandomQuoteCmd : Cmd Msg
-- fetchRandomQuoteCmd =
--   Task.perform HttpError FetchQuoteSuccess fetchRandomQuote
--
-- fetchProtectedQuote : Model -> Task Http.Error String
-- fetchProtectedQuote model =
--   { verb = "GET"
--   , headers = [ ("Authorization", "Bearer " ++ model.loginModel.token ) ]
--   , url = protectedQuoteUrl
--   , body = Http.empty
--   }
--   |> Http.send Http.defaultSettings
--   |> Http.Decorators.interpretStatus
--   |> Task.map responseText
--
-- fetchProtectedQuoteCmd : Model -> Cmd Msg
-- fetchProtectedQuoteCmd model =
--   Task.perform HttpError FetchProtectedQuoteSuccess <| fetchProtectedQuote model

-- responseText : Http.Response -> String
-- responseText response =
--   case response.value of
--     Http.Text t ->
--       t
--     _ ->
--       ""

type Msg
  = AuthMsg Auth.Messages.Msg
  | Logout

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AuthMsg subMsg ->
      let
        ( updatedLoginModel, loginCmd ) =
          Auth.Updates.update subMsg model.authModel
      in
        ( { model | authModel = updatedLoginModel }, Cmd.batch [storeModel model, Cmd.map AuthMsg loginCmd] )
    Logout ->
      ( model, Cmd.none )

view : Model -> Html Msg
view model =
  let
    -- Is the user logged in?
    loggedIn : Bool
    loggedIn =
      if String.length model.authModel.token > 0 then True else False

    -- Greet a logged in user by username
    greeting : String
    greeting =
      "Hello, " ++ model.authModel.username ++ "!"

    homeView =
      if loggedIn then
        div [] [
          div [id "greeting"] [
            h3 [ class "text-center" ] [ text greeting ]
            , p [ class "text-center" ] [ text "You have super-secret access to protected quotes."]
            , p [ class "text-center" ] [
              button [ class "btn btn-danger", onClick Logout ] [ text "Logout"]
            ]
          ]
        ]
      else
        div [] [ Html.App.map AuthMsg ( Auth.View.view model.authModel ) ]
  in
    div [ class "container-fluid" ] [
      div [ class "row" ] [
        div [ class "col-xs-12 col-lg-8 col-lg-offset-2" ] [
          nav [ class "navbar navbar-default" ] [
            div [ class "container-fluid" ] [
              div [ class "navbar-header" ] [
                div [ class "navbar-brand" ] [
                  a [ href "/" ] [
                    img [ class "brand", alt "Yadda", src "lambda_orange.png" ] []
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
      , div [ class "row" ] [
        div [ class "col-xs-12 col-lg-8 col-lg-offset-2" ] [
          homeView
        ]
      ]
    ]
