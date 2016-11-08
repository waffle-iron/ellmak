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
import Notify.Messages exposing (..)
import Notify.Model exposing (..)
import Notify.Updates exposing (..)
import Notify.View exposing (..)
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
      ( model, fetchVersionCmd model )
    Nothing ->
      let
        model = Base True False "http://localhost:3000/api/v1" "" "v0.1.0" Auth.Model.new Notify.Model.new ""
      in
        ( model , fetchVersionCmd model )

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
  | Showing
  | Hiding
  | AuthMsg Auth.Messages.Msg
  | NotifyMsg Notify.Messages.Msg
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
    Showing ->
      let
        notifyModel = model.notifyModel
        (nnm, _) = Notify.Updates.show {
          notifyModel | level = "success"
          , message = "Success!"
        }
        newModel = { model | notifyModel = nnm }
      in
        ( newModel, Cmd.none )

    Hiding ->
      let
        (nnm, _) = Notify.Updates.hide model.notifyModel
      in
        ( { model | notifyModel = nnm }, Cmd.none )

    Logout ->
      let
        authModel = model.authModel
        newAuthModel = { authModel | username = "", password = "", token = "", payload = newPayload }
        newModel = { model | authModel = newAuthModel }
      in
        ( newModel, storeModel newModel )

    HttpError err ->
      case err of
          Http.BadResponse _ msg ->
            case msg of
              "Unauthorized" ->
                let
                  authModel = model.authModel
                  newAuthModel =
                    { authModel | username = "", password = "", token = "" }
                  newModel = { model | authModel = newAuthModel }
                in
                  ( newModel, storeModelCmd newModel )
              _ -> ( model, Cmd.none )
          _ -> ( model, Cmd.none )
      |> Debug.log (toString err)

    StoreModel ->
      ( model, storeModelCmd model )

    FetchVersion ->
      ( model, fetchVersionCmd model )

    FetchVersionSuccess apiVersion ->
      let
        newModel = { model | apiVersion = apiVersion }
      in
        ( newModel, storeModelCmd newModel )

    AuthMsg subMsg ->
      let
        ( updatedAuthModel, authCmd ) =
          Auth.Updates.update subMsg model.authModel model.baseUrl
        newModel =
          { model | authModel = updatedAuthModel }
      in
        ( newModel, Cmd.batch [ storeModelCmd newModel,  Cmd.map AuthMsg authCmd ] )

    NotifyMsg subMsg ->
      let
        ( updatedNotifyModel, notifyCmd ) =
          Notify.Updates.update subMsg model.notifyModel
        newModel =
          { model | notifyModel = updatedNotifyModel }
      in
        ( newModel, Cmd.batch [ storeModelCmd newModel, Cmd.map NotifyMsg notifyCmd ] )



view : Base -> Html Msg
view model =
  let
    -- Is the user logged in?
    loggedIn : Bool
    loggedIn =
      if not <| isEmpty model.authModel.token then True else False

    -- Greet a logged in user by username
    greeting : String
    greeting =
      "Hello, " ++ model.authModel.payload.name ++ "!"

    versionText : String
    versionText =
      "Development UI " ++ model.uiVersion ++
        if isEmpty model.apiVersion then
          ""
        else
          " API " ++ model.apiVersion

    devText =
      if model.dev then
        versionText
      else
        ""

    logoutButton =
      if loggedIn then
        button [ class "btn btn-primary", onClick Logout ] [ text "Logout" ]
      else
        div [] []

    homeView =
      if loggedIn then
        div [ class "row"] [
          div [ class "col-lg-8" ] [
            div [ class "panel panel-default"] [
              div [ class "panel-heading text-right" ] [
                text model.authModel.payload.name
              ]
              , div [ class "panel-body" ] [
                div [ class "btn-group" ] [
                  button [ class "btn btn-primary", onClick Showing ] [ text "Show" ]
                  , button [ class "btn btn-primary", onClick Hiding ] [ text "Hide" ]
                ]
              ]
            ]
          ]
          , div [ class "col-lg-4" ] [
            div [ class "panel panel-default"] [
              div [ class "panel-heading" ] [ text "Noda" ]
              , div [ class "panel-body" ] [ text "Testing" ]
            ]
          ]
        ]
      else
        div [] [ Html.App.map AuthMsg ( Auth.View.view model.authModel ) ]
  in
    div [] [
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
                  ul [ class "nav navbar-nav navbar-right"] [
                    li [] [
                      p [ class "navbar-text" ] [ text devText ]
                    ]
                    , li [ class "logout-button" ] [ logoutButton ]
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
      , div [] [ Html.App.map NotifyMsg ( Notify.View.view model.notifyModel ) ]
    ]
