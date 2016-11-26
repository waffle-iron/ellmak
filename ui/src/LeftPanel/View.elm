module LeftPanel.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (map)
import LeftPanel.Messages exposing (..)
import LeftPanel.Model exposing (LeftPanel)
import Routing.Router exposing (..)


panelContent : String -> List (Html a) -> Html a
panelContent heading body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ text heading ]
        , div [ class "panel-body" ] body
        ]


helpButton : String -> Html Msg
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


helpTextWell : String -> String -> Html Msg
helpTextWell idStr helpText =
    div [ class "row" ]
        [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
            [ div [ class "collapse", id (idStr ++ "-help-well") ]
                [ div [ class "well well-sm" ] [ text helpText ]
                ]
            ]
        ]


addRepoFormGroupTextArea : Int -> String -> String -> String -> (String -> Msg) -> Html Msg
addRepoFormGroupTextArea ti idStr labelStr placeholderStr msg =
    div [ class "form-group" ]
        [ label [ for idStr, class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text labelStr ]
        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
            [ textarea [ tabindex ti, id idStr, class "form-control ta-sized", placeholder placeholderStr, onInput msg ] [] ]
        , helpButton (idStr ++ "-help-well")
        ]


addRepoFormGroupText : Int -> String -> String -> String -> (String -> Msg) -> Html Msg
addRepoFormGroupText ti idStr labelStr placeholderStr msg =
    div [ class "form-group" ]
        [ label [ for idStr, class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text labelStr ]
        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
            [ input [ tabindex ti, type_ "text", class "form-control", id idStr, placeholder placeholderStr, onInput msg ] [] ]
        , helpButton (idStr ++ "-help-well")
        ]


originFormGroup : Html Msg
originFormGroup =
    div [ class "form-group" ]
        [ label [ for "origin-name", class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text "Origin" ]
        , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
            [ div [ class "row" ]
                [ div [ class "col-lg-4 col-md-4 col-sm-4 col-xs-4" ]
                    [ input [ type_ "text", class "form-control", id "origin-name", readonly True, placeholder "origin" ] []
                    ]
                , div [ class "col-lg-8 col-md-8 col-sm-8 col-xs-8" ]
                    [ input [ type_ "text", class "form-control", id "origin-url", placeholder "Origin URL", onInput (ForSelf << SetOriginRemote) ] []
                    ]
                ]
            ]
        ]


onBlurb : (String -> msg) -> Attribute msg
onBlurb stuff =
    on "blur" (Json.Decode.map stuff targetValue)


additionalRemote : Int -> Html Msg
additionalRemote idx =
    let
        idStr =
            "remote-" ++ (toString idx)

        urlStr =
            "remote-" ++ (toString idx) ++ "-url"
    in
        div [ class "form-group" ]
            [ label [ for idStr, class "col-lg-2 col-md-3 col-sm-2 col-xs-3 control-label" ] [ text "Remote" ]
            , div [ class "col-lg-8 col-md-7 col-sm-8 col-xs-6" ]
                [ div [ class "row" ]
                    [ div [ class "col-lg-4 col-md-4 col-sm-4 col-xs-4" ]
                        [ input
                            [ type_ "text"
                            , class "form-control"
                            , id idStr
                            , placeholder "gh"
                            , onInput (ForSelf << SetAdditionalRepoKey idx)
                            , onBlurb (ForSelf << NewRemoteRow)
                            ]
                            []
                        ]
                    , div [ class "col-lg-8 col-md-8 col-sm-8 col-xs-8" ]
                        [ input
                            [ type_ "text"
                            , class "form-control"
                            , id urlStr
                            , placeholder ""
                            , onInput (ForSelf << SetAdditionalRepoValue idx)
                            ]
                            []
                        ]
                    ]
                ]
            ]


view : LeftPanel -> Html Msg
view model =
    case model.route of
        Home ->
            panelContent "Messages"
                [ p [] [ strong [] [ text "Not yet implemented!" ] ]
                ]

        EditRepo ->
            panelContent "Edit Repository"
                [ p [] [ strong [] [ text "Not yet implemented!" ] ]
                ]

        RemoveRepo ->
            panelContent "Remove Repository"
                [ p [] [ strong [] [ text "Not yet implemented!" ] ]
                ]

        AddRepo ->
            panelContent "Add Repository Monitor"
                [ Html.form [ class "form-horizontal", onSubmit (ForSelf Eat) ]
                    [ div [ class "row" ]
                        [ div [ class "col-lg-8 col-lg-offset-2 col-md-7 col-md-offset-3 col-sm-8 col-sm-offset-2 col-xs-6 col-xs-offset-3" ]
                            [ div [ class "row pad-bottom-5" ]
                                [ div [ class "col-lg-4 col-md-4 col-sm-4 col-xs-4" ]
                                    [ div [ class "text-center" ] [ strong [] [ text "Remote Name" ] ]
                                    ]
                                , div [ class "col-lg-8 col-md-8 col-sm-8 col-xs-8" ]
                                    [ div [ class "text-center" ] [ strong [] [ text "Remote URL" ] ]
                                    ]
                                ]
                            ]
                        ]
                    , originFormGroup
                    , div [] (List.map additionalRemote (List.range 0 model.remotesCount))
                    , addRepoFormGroupTextArea 2 "repo-refs" "Branches To Monitor" "origin/master" (ForSelf << SetBranches)
                    , helpTextWell "repo-refs" "Branches To Monitor Help Text"
                    , addRepoFormGroupText 3 "frequency" "Frequency" "15m" (ForSelf << SetFrequency)
                    , helpTextWell "frequency" "Frequency Help Text"
                    , addRepoFormGroupText 4 "short-name" "Short Name" "Optional: CraZySacX/ellmak" (ForSelf << SetShortName)
                    , helpTextWell "short-name" "Short Name Help Text"
                    ]
                , div [ class "row" ]
                    [ div [ class "col-lg-4 col-lg-offset-6 col-md-6 col-md-offset-4 col-sm-6 col-sm-offset-4 col-xs-6 col-xs-offset-3" ]
                        [ div [ class "btn-group pull-right" ]
                            [ button [ class "btn btn-default", tabindex 5, onClick (ForSelf ClickAddRepo) ] [ text "Add" ]
                            , button [ class "btn btn-default", tabindex 6, onClick (ForSelf ToHome) ] [ text "Cancel" ]
                            ]
                        ]
                    ]
                ]

        NotFound ->
            panelContent "Not Found"
                [ p [] [ text "The resource you have requested cannot be found" ]
                ]
