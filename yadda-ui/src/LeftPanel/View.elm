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
                [ Html.form []
                    [ div [ class "form-group" ]
                        [ label [ for "repo-url" ] [ text "Repository URL" ]
                        , div [ class "input-group" ]
                            [ input [ type_ "text", class "form-control", id "repo-url", placeholder "git@github.com:CraZySacX/yadda.git" ] []
                            , span [ class "input-group-addon", onClick ToggleUrlHelp ]
                                [ span [ class "glyphicon glyphicon-question-sign" ] []
                                ]
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ label [ for "repo-refs" ] [ text "Branches to Monitor" ]
                        , textarea [ class "form-control", id "repo-refs", placeholder "origin/master" ] []
                        ]
                    ]
                , div [ class "btn-group" ]
                    [ button [ class "btn btn-default" ] [ text "Add" ]
                    , button [ class "btn btn-default", onClick ToHome ] [ text "Cancel" ]
                    ]
                ]

        NotFound ->
            panelContent "Not Found"
                [ p [] [ text "The resource you have requested cannot be found" ]
                ]
