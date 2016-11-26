module Conversions.Environment exposing (..)

import Env.Env exposing (Environment(..))


toString : Environment -> String
toString env =
    case env of
        Development ->
            "development"

        Integration ->
            "integration"

        Staging ->
            "staging"

        Production ->
            "production"
