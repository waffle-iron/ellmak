module Routing.Router exposing (..)

import Navigation
import String
import UrlParser exposing (..)

type Route
  = Home
  | Admin
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
    _ ->
      NotFound

matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ format Home (s "")
    , format Admin ( s "admin")
    ]

hashParser : Navigation.Location -> Result String Route
hashParser location =
  location.hash
    |> String.dropLeft 1
    |> parse identity matchers

parser : Navigation.Parser (Result String Route)
parser =
  Navigation.makeParser hashParser

routeFromResult : Result String Route -> Route
routeFromResult result =
  case result of
    Ok route ->
      route

    Err string ->
      NotFound
