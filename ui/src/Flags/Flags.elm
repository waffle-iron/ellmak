module Flags.Flags exposing (..)


type alias Flags =
    { env : String
    , baseUrl : String
    , apiVersion : String
    , uiVersion : String
    , token : String
    , expiry : Float
    , route : String
    }
