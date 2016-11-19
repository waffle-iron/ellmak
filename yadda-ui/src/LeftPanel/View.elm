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


helpButton : String -> Html LeftPanelMsg
helpButton id =
    div [ class "col-lg-2 col-md-2 col-sm-2 col-xs-3" ]
        [ button
            [ class "btn btn-default"
            , type_ "button"
            , attribute "data-toggle" "collapse"
            , attribute "data-target" ("#" ++ id)
            , attribute "aria-expanded" "false"
            , attribute "aria-controls" id
            ]
            [ span [ class "glyphicon glyphicon-question-sign" ] [] ]
        ]


helpTextWell : String -> String -> Html LeftPanelMsg
helpTextWell idStr helpText =
    div [ class "row" ]
        [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
            [ div [ class "collapse", id (idStr ++ "-help-well") ]
                [ div [ class "well well-sm" ] [ text helpText ]
                ]
            ]
        ]


addRepoFormGroupTextArea : Int -> String -> String -> String -> (String -> LeftPanelMsg) -> Html LeftPanelMsg
addRepoFormGroupTextArea ti idStr labelStr placeholderStr msg =
    div [ class "form-group" ]
        [ label [ for idStr, class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text labelStr ]
        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
            [ textarea [ tabindex ti, id idStr, class "form-control", placeholder placeholderStr, onInput msg ] [] ]
        , helpButton (idStr ++ "-help-well")
        ]


addRepoFormGroupText : Int -> String -> String -> String -> (String -> LeftPanelMsg) -> Html LeftPanelMsg
addRepoFormGroupText ti idStr labelStr placeholderStr msg =
    div [ class "form-group" ]
        [ label [ for idStr, class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text labelStr ]
        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
            [ input [ tabindex ti, type_ "text", class "form-control", id idStr, placeholder placeholderStr, onInput msg ] [] ]
        , helpButton (idStr ++ "-help-well")
        ]


view : LeftPanel -> Html LeftPanelMsg
view model =
    case model.route of
        Home ->
            panelContent "Repositories"
                [ p [] [ strong [] [ text "Not yet implemented!" ] ]
                ]

        RemoveRepo ->
            panelContent "Remove Repository"
                [ p [] [ strong [] [ text "Not yet implemented!" ] ]
                ]

        AddRepo ->
            panelContent "Add Repository Monitor"
                [ Html.form [ class "form-horizontal", onSubmit Eat ]
                    [ addRepoFormGroupText 1 "repo-url" "Repository URL" "git@github.com:CraZySacX/yadda.git" SetRepoUrl
                    , helpTextWell "repo-url" "Url Help Text"
                    , addRepoFormGroupTextArea 2 "repo-refs" "Branches To Monitor" "" SetBranches
                    , helpTextWell "repo-refs" "Branches To Monitor Help Text"
                    , addRepoFormGroupText 3 "frequency" "Frequency" "15m" SetFrequency
                    , helpTextWell "frequency" "Frequency Help Text"
                    , addRepoFormGroupText 4 "short-name" "Short Name" "Optional: CraZySacX/yadda" SetShortName
                    , helpTextWell "short-name" "Short Name Help Text"
                    ]
                , div [ class "row" ]
                    [ div [ class "col-lg-4 col-lg-offset-6 col-md-6 col-md-offset-4 col-sm-6 col-sm-offset-4 col-xs-6 col-xs-offset-3" ]
                        [ div [ class "btn-group pull-right" ]
                            [ button [ class "btn btn-default", tabindex 5, onClick ClickAddRepo ] [ text "Add" ]
                            , button [ class "btn btn-default", tabindex 6, onClick ToHome ] [ text "Cancel" ]
                            ]
                        ]
                    ]
                ]

        NotFound ->
            panelContent "Not Found"
                [ p [] [ text "The resource you have requested cannot be found" ]
                ]
