module RightPanel.Model exposing (..)

import Repo.Model exposing (Repository)


type alias RightPanel =
    { repos : List Repository
    }


defaultRightPanel : RightPanel
defaultRightPanel =
    { repos = []
    }
