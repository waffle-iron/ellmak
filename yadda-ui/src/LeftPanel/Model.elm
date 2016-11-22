module LeftPanel.Model exposing (..)

import Dict exposing (Dict, empty)
import Routing.Router exposing (Route(Home))


type alias LeftPanel =
    { route : Route
    , remotesCount : Int
    , remotesDict : Dict String String
    , addRemotesDict : Dict Int ( String, String )
    , branches : List String
    , frequency : String
    , shortName : String
    }


defaultLeftPanel : LeftPanel
defaultLeftPanel =
    { route = Home
    , remotesCount = 0
    , remotesDict = Dict.empty
    , addRemotesDict = Dict.empty
    , branches = []
    , frequency = ""
    , shortName = ""
    }
