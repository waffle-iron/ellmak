module LeftPanel.Model exposing (..)

import Routing.Router exposing (Route(Home))


type alias LeftPanel =
    { urlHelp : Bool
    , branchHelp : Bool
    , route : Route
    }


defaultLeftPanel : LeftPanel
defaultLeftPanel =
    { urlHelp = False
    , branchHelp = False
    , route = Home
    }
