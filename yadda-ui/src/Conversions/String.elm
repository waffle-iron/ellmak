module Conversions.String exposing (..)

import Env.Env exposing (Environment(..))
import Routing.Router exposing (Route(..))


toRoute : String -> Route
toRoute str =
    case str of
        "" ->
            Home

        "Home" ->
            Home

        "AddRepo" ->
            AddRepo

        _ ->
            NotFound


toEnvironment : String -> Environment
toEnvironment env =
    case env of
        "development" ->
            Development

        "integration" ->
            Integration

        "staging" ->
            Staging

        "production" ->
            Production

        _ ->
            Development
