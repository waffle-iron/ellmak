module RightPanel.View exposing (..)

import Base.Model exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Repo.Model exposing (Repository)
import RightPanel.Messages exposing (RightPanelMsg(..))
import RightPanel.Model exposing (RightPanel)


panelContent : String -> List (Html a) -> Html a
panelContent heading body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ text heading ]
        , div [ class "panel-body" ] body
        ]


repoPanel : Int -> ( String, Repository ) -> Html RightPanelMsg
repoPanel idx repoTuple =
    let
        shortName =
            Tuple.first repoTuple

        repo =
            Tuple.second repoTuple

        idStr =
            "heading-" ++ (toString idx)

        collStr =
            "collapse-" ++ (toString idx)

        hrefStr =
            "#" ++ collStr
    in
        div [ class "panel panel-default" ]
            [ div [ class "panel-heading", attribute "role" "tab", id idStr ]
                [ h4 [ class "panel-title" ]
                    [ a
                        [ attribute "role" "button"
                        , attribute "data-toggle" "collapse"
                        , attribute "data-parent" "#right-accordion"
                        , href hrefStr
                        , attribute "aria-expanded" "true"
                        , attribute "aria-controls" collStr
                        ]
                        [ text shortName ]
                    ]
                ]
            , div [ class "panel-collapse collapse", id collStr ]
                [ div [ class "panel-body" ]
                    [ text "One"
                    ]
                ]
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
                    [ Html.form [ onSubmit NoOp ]
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
                        (List.indexedMap repoPanel <| Dict.toList model.repos)
                    ]
                ]
            ]
