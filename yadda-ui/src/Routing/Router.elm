module Routing.Router exposing (..)

import Navigation
import UrlParser exposing (..)


type Route
    = Home
    | AddRepo
    | RemoveRepo
    | NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top
        , map AddRepo (s "addrepo")
        , map RemoveRepo (s "removerepo")
        ]


hashParser : Navigation.Location -> Maybe Route
hashParser location =
    parseHash matchers location


routeFromMaybe : Maybe Route -> Route
routeFromMaybe maybeRoute =
    case maybeRoute of
        Just route ->
            route

        Nothing ->
            NotFound
