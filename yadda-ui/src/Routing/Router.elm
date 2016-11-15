module Routing.Router exposing (..)

import Navigation
import UrlParser exposing (..)


type Route
    = Home
    | Admin
    | AddRepo
    | NotFound


fromString : String -> Route
fromString routeStr =
    case routeStr of
        "" ->
            Home

        "Home" ->
            Home

        "Admin" ->
            Admin

        "AddRepo" ->
            AddRepo

        _ ->
            NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map Home top
        , map Admin (s "admin")
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
