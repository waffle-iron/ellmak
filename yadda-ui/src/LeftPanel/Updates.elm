module LeftPanel.Updates exposing (..)

import LeftPanel.Messages exposing (LeftPanelMsg(..))
import LeftPanel.Model exposing (LeftPanel)
import Navigation exposing (newUrl)


update : LeftPanelMsg -> LeftPanel -> ( LeftPanel, Cmd LeftPanelMsg )
update msg model =
    case msg of
        ToggleUrlHelp ->
            ( { model | urlHelp = True }, Cmd.none )

        ToggleBranchHelp ->
            ( { model | branchHelp = True }, Cmd.none )

        ToHome ->
            ( model, newUrl ("#") )
