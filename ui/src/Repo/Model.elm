module Repo.Model exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)


type alias Reference =
    { ref : String
    , lastUpdated : Time
    }


type alias Repository =
    { remotes : Dict String String
    , refs : List Reference
    , frequency : String
    , shortName : String
    }
