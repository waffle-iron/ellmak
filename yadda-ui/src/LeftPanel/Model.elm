module LeftPanel.Model exposing (..)

import Routing.Router exposing (Route(Home))


type alias LeftPanel =
    { baseUrl : String
    , token : String
    , route : Route
    , repoUrl : String
    , branches : List String
    , frequency : String
    , shortName : String
    }


defaultLeftPanel : LeftPanel
defaultLeftPanel =
    { baseUrl = ""
    , token = ""
    , route = Home
    , repoUrl = ""
    , branches = []
    , frequency = ""
    , shortName = ""
    }
