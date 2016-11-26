module Auth.View exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (Authentication)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


view : Authentication -> Html Msg
view auth =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ text "Login" ]
        , div [ class "panel-body" ]
            [ div [ class "form-horizontal" ]
                [ div [ class "form-group" ]
                    [ label [ for "username", class "col-md-2 control-label" ] [ text "Username: " ]
                    , div [ class "col-md-10" ]
                        [ input [ id "username", type_ "text", class "form-control", Html.Attributes.value auth.username, onInput (ForSelf << SetUsername) ] []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ label [ for "password", class "col-md-2 control-label" ] [ text "Password: " ]
                    , div [ class "col-md-10" ]
                        [ input [ id "password", type_ "password", class "form-control", Html.Attributes.value auth.password, onInput (ForSelf << SetPassword) ] []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-md-offset-10 col-md-2" ]
                        [ button [ class "btn btn-default btn-block", onClick (ForSelf Login) ] [ text "Login" ]
                        ]
                    ]
                ]
            ]
        ]
