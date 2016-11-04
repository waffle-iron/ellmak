module Model exposing (..)

import Auth.Model exposing (Authentication)

type alias Model =
  { authModel: Authentication
  , quoteModel: String
  }
