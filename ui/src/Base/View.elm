module Base.View exposing (..)

import Auth.View exposing (..)
import Base.Messages exposing (..)
import Base.Model exposing (BaseModel)
import Base.Updates exposing (authTranslator, leftPanelTranslator)
import Html exposing (..)
import Html.Attributes exposing (..)
import LeftPanel.View exposing (..)
import Navbar.View exposing (view)
import RightPanel.View exposing (..)


authenticatedContent : BaseModel -> Html BaseMsg
authenticatedContent model =
    div [ class "row" ]
        [ div [ class "col-lg-8 col-md-12 col-sm-12 col-xs-12" ]
            [ Html.map leftPanelTranslator (LeftPanel.View.view model.leftPanel)
            ]
        , div [ class "col-lg-4 col-md-12 col-sm-12 col-xs-12" ]
            [ Html.map RightPanelMsg (RightPanel.View.view model.rightPanel)
            ]
        ]


mainContent : BaseModel -> Html BaseMsg
mainContent model =
    if model.authentication.authenticated then
        authenticatedContent model
    else
        Html.map authTranslator (Auth.View.view model.authentication)


view : BaseModel -> Html BaseMsg
view model =
    div [ class "container-fluid" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-12 col-md-12 col-sm-12 col-xs-12" ]
                [ Html.map NavMsg (Navbar.View.view model)
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col-lg-12 col-md-12 col-sm-12 col-xs-12" ]
                [ mainContent model
                ]
            ]
        ]
