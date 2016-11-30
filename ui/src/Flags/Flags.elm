module Flags.Flags exposing (..)


type alias Flags =
    { env : String
    , randomSeed : Int
    , baseUrl : String
    , wsBaseUrl : String
    , apiVersion : String
    , uiVersion : String
    , username : String
    , token : String
    , expiry : Float
    , route : String
    }
