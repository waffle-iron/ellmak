module Repo.Model exposing (..)


type alias Repository =
    { url : String
    , branches : List String
    , frequency : String
    , shortName : String
    }
