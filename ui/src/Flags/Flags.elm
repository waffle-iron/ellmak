module Flags.Flags exposing (..)


type alias Flags =
    { env : String
    , baseUrl : String
    , wsBaseUrl : String
    , apiVersion : String
    , uiVersion : String
    , token : String
    , expiry : Float
    , route : String
    }
