module RightPanel.Updates exposing (..)

import Navigation exposing (newUrl)
import RightPanel.Messages exposing (RightPanelMsg(..))
import RightPanel.Model exposing (RightPanel)


update : RightPanelMsg -> RightPanel -> ( RightPanel, Cmd RightPanelMsg )
update msg model =
    case msg of
        ToAdd ->
            ( model, newUrl ("#addrepo") )

        ToRemove ->
            ( model, newUrl ("#removerepo") )

        Eat ->
            ( model, Cmd.none )
