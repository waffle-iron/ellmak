module Model exposing (..)

import Auth.Model exposing (Authentication)

type alias Base =
  { dev: Bool
  , prod: Bool
  , baseUrl: String
  , blah: String
  , authModel: Authentication
  , quoteModel: String
  }
