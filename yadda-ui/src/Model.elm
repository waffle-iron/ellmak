module Model exposing (..)

import Auth.Model exposing (Authentication)
import Notify.Model exposing (Notification)

type alias Base =
  { dev: Bool
  , prod: Bool
  , baseUrl: String
  , apiVersion: String
  , uiVersion: String
  , authModel: Authentication
  , notifyModel: Notification
  , quoteModel: String
  }
