module Routing.Router exposing (..)

import Navigation
import UrlParser exposing (..)


type Route
    = Home
    | AddRepo
    | NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top
        , map AddRepo (s "addrepo")
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
