module Navbar.View exposing (..)

import Base.Model exposing (BaseModel)
import Env.Env exposing (Environment(Development))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Navbar.Messages exposing (..)
import String exposing (isEmpty)


versionText : BaseModel -> String
versionText model =
    "Development UI "
        ++ model.uiVersion
        ++ if isEmpty model.apiVersion then
            ""
           else
            " API " ++ model.apiVersion


view : BaseModel -> Html NavbarMsg
view model =
    let
        devText =
            case model.env of
                Development ->
                    p [ class "navbar-text" ] [ text <| versionText model ]

                _ ->
                    Html.text ""

        logoutButton =
            if model.authentication.authenticated then
                button [ class "btn btn-default navbar-btn", onClick Logout ] [ text "Logout" ]
            else
                Html.text ""
    in
        nav [ class "navbar navbar-default" ]
            [ div [ class "container-fluid" ]
                [ div [ class "navbar-header" ]
                    [ button
                        [ type_ "button"
                        , class "navbar-toggle collapsed"
                        , attribute "data-toggle" "collapse"
                        , attribute "data-target" "#navbar-collapse-1"
                        , attribute "aria-expanded" "false"
                        ]
                        [ span [ class "sr-only" ] [ text "Toggle Navigation" ]
                        , span [ class "icon-bar" ] []
                        , span [ class "icon-bar" ] []
                        , span [ class "icon-bar" ] []
                        ]
                    , a [ class "navbar-brand", href "#" ]
                        [ img [ class "brand", alt "ellmak", src "lambda_orange.png" ] []
                        ]
                    ]
                , div [ class "collapse navbar-collapse", id "navbar-collapse-1" ]
                    [ div [ class "nav navbar-nav navbar-right" ]
                        [ devText
                        , logoutButton
                        ]
                    ]
                ]
            ]
