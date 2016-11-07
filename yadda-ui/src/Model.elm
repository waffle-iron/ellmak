module Model exposing (..)

import Auth.Model exposing (Authentication)

type alias Base =
  { dev: Bool
  , prod: Bool
  , baseUrl: String
  , apiVersion: String
  , uiVersion: String
  , authModel: Authentication
  , quoteModel: String
  }
