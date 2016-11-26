module Conversions.Route exposing (..)

import Routing.Router exposing (Route(..))


toString : Route -> String
toString route =
    case route of
        Home ->
            "home"

        AddRepo ->
            "addrepo"

        EditRepo ->
            "editrepo"

        RemoveRepo ->
            "removerepo"

        NotFound ->
            "notfound"
