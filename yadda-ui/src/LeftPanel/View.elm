module LeftPanel.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LeftPanel.Messages exposing (LeftPanelMsg(..))
import LeftPanel.Model exposing (LeftPanel)
import Routing.Router exposing (..)


panelContent : String -> List (Html a) -> Html a
panelContent heading body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ text heading ]
        , div [ class "panel-body" ] body
        ]


view : LeftPanel -> Html LeftPanelMsg
view model =
    case model.route of
        Home ->
            panelContent "Repositories"
                [ p [] [ strong [] [ text "Repos will be here!" ] ]
                ]

        AddRepo ->
            panelContent "Add Repository"
                [ Html.form [ class "form-horizontal", onSubmit Eat ]
                    [ div [ class "form-group" ]
                        [ label [ for "repo-url", class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ]
                            [ text "Repository URL"
                            ]
                        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
                            [ input
                                [ type_ "text"
                                , class "form-control"
                                , id "repo-url"
                                , placeholder "git@github.com:CraZySacX/yadda.git"
                                ]
                                []
                            ]
                        , div [ class "col-lg-2 col-md-2 col-sm-2 col-xs-3" ]
                            [ button
                                [ class "btn btn-default"
                                , type_ "button"
                                , attribute "data-toggle" "collapse"
                                , attribute "data-target" "#url-help-well"
                                , attribute "aria-expanded" "false"
                                , attribute "aria-controls" "url-help-well"
                                ]
                                [ span [ class "glyphicon glyphicon-question-sign" ] [] ]
                            ]
                        ]
                    , div [ class "row" ]
                        [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
                            [ div [ class "collapse", id "url-help-well" ]
                                [ div [ class "well well-sm" ]
                                    [ text "Url Help Text"
                                    ]
                                ]
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ label [ for "repo-refs", class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ]
                            [ text "Branches to Monitor"
                            ]
                        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
                            [ textarea [ class "form-control", id "repo-refs", placeholder "origin/master" ] []
                            ]
                        , div [ class "col-lg-2 col-md-2 col-sm-2 col-xs-3" ]
                            [ button
                                [ class "btn btn-default"
                                , type_ "button"
                                , attribute "data-toggle" "collapse"
                                , attribute "data-target" "#branches-help-well"
                                , attribute "aria-expanded" "false"
                                , attribute "aria-controls" "branches-help-well"
                                ]
                                [ span [ class "glyphicon glyphicon-question-sign" ] [] ]
                            ]
                        ]
                    , div [ class "row" ]
                        [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
                            [ div [ class "collapse", id "branches-help-well" ]
                                [ div [ class "well well-sm" ]
                                    [ text "Branches To Monitor Help Text"
                                    ]
                                ]
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ label [ for "frequency", class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text "Frequency" ]
                        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
                            [ input [ type_ "text", class "form-control", id "frequency", placeholder "15m" ] []
                            ]
                        , div [ class "col-lg-2 col-md-2 col-sm-2 col-xs-3" ]
                            [ button
                                [ class "btn btn-default"
                                , type_ "button"
                                , attribute "data-toggle" "collapse"
                                , attribute "data-target" "#frequency-help-well"
                                , attribute "aria-expanded" "false"
                                , attribute "aria-controls" "frequency-help-well"
                                ]
                                [ span [ class "glyphicon glyphicon-question-sign" ] [] ]
                            ]
                        ]
                    , div [ class "row" ]
                        [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
                            [ div [ class "collapse", id "frequency-help-well" ]
                                [ div [ class "well well-sm" ]
                                    [ text "Frequency Help Text"
                                    ]
                                ]
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ label [ for "frequency", class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text "Short Name" ]
                        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
                            [ input [ type_ "text", class "form-control", id "short-name", placeholder "Optional: CraZySacX/yadda" ] []
                            ]
                        , div [ class "col-lg-2 col-md-2 col-sm-2 col-xs-3" ]
                            [ button
                                [ class "btn btn-default"
                                , type_ "button"
                                , attribute "data-toggle" "collapse"
                                , attribute "data-target" "#short-name-help-well"
                                , attribute "aria-expanded" "false"
                                , attribute "aria-controls" "short-name-well"
                                ]
                                [ span [ class "glyphicon glyphicon-question-sign" ] [] ]
                            ]
                        ]
                    ]
                , div [ class "row" ]
                    [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
                        [ div [ class "collapse", id "short-name-help-well" ]
                            [ div [ class "well well-sm" ]
                                [ text "Short Name Help Text"
                                ]
                            ]
                        ]
                    ]
                , div [ class "row" ]
                    [ div [ class "col-lg-4 col-lg-offset-6 col-md-6 col-md-offset-4 col-sm-6 col-sm-offset-4 col-xs-6 col-xs-offset-3" ]
                        [ div [ class "btn-group pull-right" ]
                            [ button [ class "btn btn-default" ] [ text "Add" ]
                            , button [ class "btn btn-default", onClick ToHome ] [ text "Cancel" ]
                            ]
                        ]
                    ]
                ]

        NotFound ->
            panelContent "Not Found"
                [ p [] [ text "The resource you have requested cannot be found" ]
                ]
