module Main exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (..)
import Auth.Updates exposing (..)
import Auth.View exposing (..)
import Html exposing (..)
import Html.App exposing (map, program)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Model exposing (Base)
import Ports exposing (storeModel, removeModel)
import String exposing (..)
import Task exposing (..)

main : Program (Maybe Base)
main =
  Html.App.programWithFlags
    { init = init
    , update = update
    , subscriptions = \_ -> Sub.none
    , view = view
    }

init : Maybe Base -> (Base, Cmd Msg)
init model =
  case model of
    Just model ->
      ( model, Cmd.none )
    Nothing ->
      ( Base True False "http://localhost:3000/api/v1" "" Auth.Model.new "" , Cmd.none )

versionDecoder : Decoder String
versionDecoder =
  "version" := Decode.string

fetchVersion : Base -> Task Http.Error String
fetchVersion model =
  { verb = "GET"
  , headers = [ ("Authorization", "Bearer " ++ model.authModel.token ) ]
  , url = model.baseUrl
  , body = Http.empty
  }
  |> Http.send Http.defaultSettings
  |> Http.fromJson versionDecoder

fetchVersionCmd : Base -> Cmd Msg
fetchVersionCmd model =
  Task.perform HttpError FetchVersionSuccess <| fetchVersion model

type Msg
  = Logout
  | AuthMsg Auth.Messages.Msg
  | FetchVersion
  | FetchVersionSuccess String
  | HttpError Http.Error
  | StoreModel

storeModelCmd : Base -> Cmd Msg
storeModelCmd model =
  storeModel model

update : Msg -> Base -> (Base, Cmd Msg)
update msg model =
  case msg of
    Logout ->
      ( model, Cmd.none )

    HttpError err ->
      ( model, Cmd.none ) |> Debug.log (toString err)

    StoreModel ->
      ( model, storeModelCmd model )

    FetchVersion ->
      ( model, fetchVersionCmd model )

    FetchVersionSuccess version ->
      let
        newModel = { model | blah = version }
      in
        ( newModel, storeModelCmd newModel ) |> Debug.log "Blah"

    AuthMsg subMsg ->
      let
        ( updatedAuthModel, authCmd ) =
          Auth.Updates.update subMsg model.authModel model.baseUrl
        newModel =
          { model | authModel = updatedAuthModel }
      in
        ( newModel, Cmd.batch [ storeModelCmd newModel,  Cmd.map AuthMsg authCmd ] )



view : Base -> Html Msg
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

    devText =
      if model.dev then
        p [ class "navbar-text navbar-right"] [ text ("Development" ++ model.blah) ]
      else
        p [] []

    homeView =
      if loggedIn then
        div [] [
          div [id "greeting"] [
            h3 [ class "text-center" ] [ text greeting ]
            , p [ class "text-center" ] [ text "You have super-secret access to protected quotes."]
            , p [ class "text-center" ] [
              button [ class "btn btn-danger", onClick FetchVersion ] [ text "Version"]
              , button [ class "btn btn-danger", onClick Logout ] [ text "Logout"]
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
              , div [ class "collapse navbar-collapse", id "navbar-collapse-1"] [
                devText
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
