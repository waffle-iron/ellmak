module Base.View exposing (..)

import Auth.View exposing (..)
import Base.Messages exposing (..)
import Base.Model exposing (BaseModel)
import Html exposing (..)
import Html.App exposing (map)
import Html.Attributes exposing (..)
import LeftPanel.View exposing (..)
import Navbar.View exposing (view)
import Notify.View exposing (..)
import RightPanel.View exposing (..)

authenticatedContent : BaseModel -> Html BaseMsg
authenticatedContent model =
  div [ class "row"] [
    div [ class "col-lg-8"] [ LeftPanel.View.view model ]
    , div [ class "col-lg-4" ] [ RightPanel.View.view model ]
  ]

mainContent : BaseModel -> Html BaseMsg
mainContent model =
  if model.authModel.authenticated then
    authenticatedContent model
  else
    map AuthMsg ( Auth.View.view model.authModel )

view : BaseModel -> Html BaseMsg
view model =
  div [] [
    div [ class "container-fluid" ] [
      div [ class "row" ] [
        div [ class "col-lg-8 col-lg-offset-2" ] [
          map NavMsg ( Navbar.View.view model )
        ]
      ]
      , div [ class "row" ] [
        div [ class "col-lg-8 col-lg-offset-2" ] [
          mainContent model
        ]
      ]
    ]
    , map NotifyMsg ( Notify.View.view model.notifyModel )
  ]
