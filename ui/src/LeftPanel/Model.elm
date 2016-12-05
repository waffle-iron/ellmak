module LeftPanel.Model exposing (..)

import Dict exposing (Dict, empty)
import Routing.Router exposing (Route(Home))
import Time exposing (Time)


type alias LeftPanel =
    { route : Route
    , remotesCount : Int
    , remotesDict : Dict String ( String, Time )
    , addRemotesDict : Dict Int ( String, ( String, Time ) )
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
