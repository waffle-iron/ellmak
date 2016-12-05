module Repo.Model exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)


type alias Repository =
    { remotes : Dict String ( String, Time )
    , branches : List String
    , frequency : String
    , shortName : String
    }
