module LeftPanel.Model exposing (..)

import Routing.Router exposing (Route(Home))


type alias LeftPanel =
    { route : Route
    , repoUrl : String
    , branches : List String
    , frequency : String
    , shortName : String
    }


defaultLeftPanel : LeftPanel
defaultLeftPanel =
    { route = Home
    , repoUrl = ""
    , branches = []
    , frequency = ""
    , shortName = ""
    }
