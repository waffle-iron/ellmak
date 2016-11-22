module RightPanel.Model exposing (..)

import Dict exposing (Dict)
import Repo.Model exposing (Repository)


type alias RightPanel =
    { repos : Dict String Repository
    }


defaultRightPanel : RightPanel
defaultRightPanel =
    { repos = Dict.empty
    }
