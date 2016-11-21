module LeftPanel.Updates exposing (..)

import LeftPanel.Messages exposing (..)
import LeftPanel.Model exposing (LeftPanel)
import Navigation exposing (newUrl)
import String exposing (split)
import Task exposing (perform, succeed)


generateParentMsg : ExternalMsg -> Cmd Msg
generateParentMsg externalMsg =
    Task.perform ForParent (Task.succeed externalMsg)


update : InternalMsg -> LeftPanel -> ( LeftPanel, Cmd Msg )
update msg model =
    case msg of
        ToHome ->
            ( model, newUrl ("#") )

        Eat ->
            ( model, Cmd.none )

        ClickAddRepo ->
            ( model, generateParentMsg <| PostRepo model )

        SetRepoUrl repoUrl ->
            ( { model | repoUrl = repoUrl }, Cmd.none )

        SetRemotes remotesStr ->
            let
                remotes =
                    split "\n" remotesStr
            in
                ( { model | remotes = remotes }, Cmd.none )

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
