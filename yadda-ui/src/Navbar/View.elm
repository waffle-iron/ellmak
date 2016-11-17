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
                button [ class "btn btn-default", onClick Logout ] [ text "Logout" ]
            else
                Html.text ""
    in
        nav [ class "navbar navbar-default" ]
            [ div [ class "container-fluid" ]
                [ div [ class "navbar-header" ]
                    [ div [ class "navbar-brand" ]
                        [ a [ href "/" ]
                            [ img [ class "brand", alt "Yadda", src "lambda_orange.png" ] []
                            ]
                        ]
                    ]
                , div [ class "collapse navbar-collapse", id "navbar-collapse-1" ]
                    [ ul [ class "nav navbar-nav navbar-right" ]
                        [ li [] [ devText ]
                        , li [ class "logout-button" ] [ logoutButton ]
                        ]
                    ]
                ]
            ]
