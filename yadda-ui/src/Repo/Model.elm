module Repo.Model exposing (..)

import Dict exposing (Dict)


type alias Repository =
    { remotes : Dict String String
    , branches : List String
    , frequency : String
    , shortName : String
    }
