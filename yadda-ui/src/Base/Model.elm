module Base.Model exposing (..)

import Auth.Model exposing (Authentication)
import Notify.Model exposing (Notification)
import Routing.Router exposing (..)

type alias AlertifyConfig =
  { message: String
  , position: String
  , maxItems: Int
  , closeDelay: Int
  , cloc: Bool
  , logType: String
  }

newConfig : AlertifyConfig
newConfig =
  { message = ""
  , position = "top center"
  , maxItems = 2
  , closeDelay = 3000
  , cloc = False
  , logType = "success"
  }

type alias BaseFlags =
  { dev: Bool
  , prod: Bool
  , baseUrl: String
  , apiVersion: String
  , uiVersion: String
  , authModel: Authentication
  , notifyModel: Notification
  , route: String
  }

type alias BaseModel =
  { dev: Bool
  , prod: Bool
  , baseUrl: String
  , apiVersion: String
  , uiVersion: String
  , authModel: Authentication
  , notifyModel: Notification
  , route: Route
  }

modelToFlags : BaseModel -> BaseFlags
modelToFlags model =
  BaseFlags
    model.dev
    model.prod
    model.baseUrl
    model.apiVersion
    model.uiVersion
    model.authModel
    model.notifyModel
    (toString model.route)

modelFromFlags : Maybe BaseFlags -> Route -> BaseModel
modelFromFlags maybeFlags route =
  case maybeFlags of
    Nothing ->
      let
        model = new
      in
        { model | route = route }

    Maybe.Just flags ->
      BaseModel
        flags.dev
        flags.prod
        flags.baseUrl
        flags.apiVersion
        flags.uiVersion
        flags.authModel
        flags.notifyModel
        (fromString flags.route)

new : BaseModel
new =
  { dev = True
  , prod = False
  , baseUrl = "http://localhost:3000/api/v1"
  , apiVersion = ""
  , uiVersion = "v0.1.0"
  , authModel = Auth.Model.new
  , notifyModel = Notify.Model.new
  , route = Home
  }
