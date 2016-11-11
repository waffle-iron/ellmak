module Base.View exposing (..)

import Auth.View exposing (..)
import Base.Messages exposing (..)
import Base.Model exposing (BaseModel)
import Html exposing (..)
import Html.App exposing (map)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Navbar.View exposing (view)
import Notify.View exposing (..)
import Routing.Router exposing (..)

authenticatedContent : BaseModel -> Html BaseMsg
authenticatedContent model =
  let
    leftPanel =
      case model.route of
        Home ->
          div [ class "panel panel-default"] [
            div [ class "panel-heading" ] [
              text model.authModel.payload.name
            ]
            , div [ class "panel-body" ] [
              button [ class "btn btn-primary", onClick Show ] [ text "Show" ]
              , button [ class "btn btn-danger", onClick ToAdmin ] [ text "Admin" ]
            ]
          ]
        Admin ->
          div [ class "panel panel-default"] [
            div [ class "panel-heading" ] [ text "Admin" ]
            , div [ class "panel-body" ] [
              button [ class "btn btn-primary", onClick Show ] [ text "Show" ]
              , button [ class "btn btn-danger", onClick ToHome ] [ text "Home" ]
            ]
          ]
        NotFound ->
          div [] []
  in
    div [ class "row"] [
      div [ class "col-lg-8"] [
        leftPanel
      ]
      , div [ class "col-lg-4" ] [
        div [ class "panel panel-default"] [
          div [ class "panel-heading" ] [ text "Noda" ]
          , div [ class "panel-body" ] [ text "Testing" ]
        ]
      ]
    ]

mainContent : BaseModel -> Html BaseMsg
mainContent model =
  if model.authModel.authenticated then
    authenticatedContent model
  else
    map AuthMsg ( Auth.View.view model.authModel )

view : BaseModel -> Html BaseMsg
view model =
  let
    greeting : String
    greeting =
      "Hello, " ++ model.authModel.payload.name ++ "!"

  in
    div [] [
      div [ class "container-fluid" ] [
        div [ class "row" ] [
          div [ class "col-xs-12 col-lg-8 col-lg-offset-2" ] [
            map NavMsg ( Navbar.View.view model )
          ]
        ]
        , div [ class "row" ] [
          div [ class "col-xs-12 col-lg-8 col-lg-offset-2" ] [
            mainContent model
          ]
        ]
      ]
      , map NotifyMsg ( Notify.View.view model.notifyModel )
    ]
