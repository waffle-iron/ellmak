module RightPanel.View exposing (..)

import Base.Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RightPanel.Messages exposing (RightPanelMsg(..))
import RightPanel.Model exposing (RightPanel)


panelContent : String -> List (Html a) -> Html a
panelContent heading body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ text heading ]
        , div [ class "panel-body" ] body
        ]


view : RightPanel -> Html RightPanelMsg
view model =
    let
        baseConfig =
            Base.Model.newConfig

        config =
            { baseConfig | message = "Testing!!!" }
    in
        panelContent "Repository Management"
            [ div [ class "row" ]
                [ div [ class "col-lg-12 col-md-12 col-sm-12 col-xs-12" ]
                    [ Html.form [ onSubmit Eat ]
                        [ div [ class "form-group" ]
                            [ div [ class "input-group" ]
                                [ input [ type_ "text", class "form-control", placeholder "Search Repositories" ] []
                                , div [ class "input-group-btn" ]
                                    [ button [ class "btn btn-default", onClick ToAdd ]
                                        [ span [ class "glyphicon glyphicon-plus-sign" ] []
                                        ]
                                    , button [ class "btn btn-default", onClick ToRemove ]
                                        [ span [ class "glyphicon glyphicon-minus-sign" ] []
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            , div [ class "row" ]
                [ div [ class "col-lg-12 col-md-12 col-sm-12 col-xs-12" ]
                    [ div
                        [ class "panel-group"
                        , id "right-accordion"
                        , attribute "role" "tablist"
                        , attribute "aria-multiselectable" "true"
                        ]
                        [ div [ class "panel panel-default" ]
                            [ div [ class "panel-heading", attribute "role" "tab", id "headingOne" ]
                                [ h4 [ class "panel-title" ]
                                    [ a
                                        [ attribute "role" "button"
                                        , attribute "data-toggle" "collapse"
                                        , attribute "data-parent" "#right-accordion"
                                        , href "#collapseOne"
                                        , attribute "aria-expanded" "true"
                                        , attribute "aria-controls" "collapseOne"
                                        ]
                                        [ text "One" ]
                                    ]
                                ]
                            , div [ class "panel-collapse collapse", id "collapseOne" ]
                                [ div [ class "panel-body" ]
                                    [ text "One"
                                    ]
                                ]
                            ]
                        , div [ class "panel panel-default" ]
                            [ div [ class "panel-heading", attribute "role" "tab", id "headingTwo" ]
                                [ h4 [ class "panel-title" ]
                                    [ a
                                        [ attribute "role" "button"
                                        , attribute "data-toggle" "collapse"
                                        , attribute "data-parent" "#right-accordion"
                                        , href "#collapseTwo"
                                        , attribute "aria-expanded" "true"
                                        , attribute "aria-controls" "collapseTwo"
                                        ]
                                        [ text "Two" ]
                                    ]
                                ]
                            , div [ class "panel-collapse collapse", id "collapseTwo" ]
                                [ div [ class "panel-body" ]
                                    [ text "Two"
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
