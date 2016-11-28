module LeftPanel.Updates exposing (..)

import Dict exposing (Dict, insert)
import LeftPanel.Messages exposing (..)
import LeftPanel.Model exposing (LeftPanel)
import Navigation exposing (newUrl)
import String exposing (split)
import Task exposing (perform, succeed)


generateParentMsg : ExternalMsg -> Cmd Msg
generateParentMsg externalMsg =
    Task.perform ForParent (Task.succeed externalMsg)


insertValue : Int -> String -> Dict Int ( String, String ) -> Dict Int ( String, String )
insertValue idx value dict =
    case (Dict.get idx dict) of
        Just ( k, _ ) ->
            Dict.insert idx ( k, value ) dict

        Nothing ->
            Dict.insert idx ( "", value ) dict


insertKey : Int -> String -> Dict Int ( String, String ) -> Dict Int ( String, String )
insertKey idx key dict =
    case (Dict.get idx dict) of
        Just ( _, v ) ->
            Dict.insert idx ( key, v ) dict

        Nothing ->
            Dict.insert idx ( key, "" ) dict


update : InternalMsg -> LeftPanel -> ( LeftPanel, Cmd Msg )
update msg model =
    case msg of
        ToHome ->
            ( model, newUrl ("#") )

        Eat ->
            ( model, Cmd.none )

        NewRemoteRow val ->
            case (String.isEmpty val) of
                True ->
                    ( model, Cmd.none )

                False ->
                    ( { model | remotesCount = model.remotesCount + 1 }, Cmd.none )

        ClickAddRepo ->
            ( model, generateParentMsg <| PostRepo model )

        ClickSendMessage ->
            ( model, generateParentMsg <| SendWsMessage "testing" )

        SetOriginRemote repoUrl ->
            let
                { remotesDict } =
                    model

                newRemotesDict =
                    Dict.insert "origin" repoUrl remotesDict

                newModel =
                    { model | remotesDict = newRemotesDict }
            in
                ( newModel, Cmd.none )

        SetAdditionalRepoKey idx key ->
            let
                { addRemotesDict } =
                    model

                newAddRemotesDict =
                    insertKey idx key addRemotesDict

                newModel =
                    { model | addRemotesDict = newAddRemotesDict }
            in
                ( newModel, Cmd.none )

        SetAdditionalRepoValue idx value ->
            let
                { addRemotesDict } =
                    model

                newAddRemotesDict =
                    insertValue idx value addRemotesDict

                newModel =
                    { model | addRemotesDict = newAddRemotesDict }
            in
                ( newModel, Cmd.none )

        SetBranches branchStr ->
            let
                branches =
                    split "\n" branchStr
            in
                ( { model | branches = branches }, Cmd.none )

        SetFrequency frequency ->
            ( { model | frequency = frequency }, Cmd.none )

        SetShortName shortName ->
            ( { model | shortName = shortName }, Cmd.none )
