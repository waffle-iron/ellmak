module Base.Messages exposing (..)

import Auth.Messages exposing (..)
import Base.Model exposing (AlertifyConfig)
import Http
import Navbar.Messages exposing (..)
import Navigation exposing (Location)


type BaseMsg
    = AuthMsg Auth.Messages.InternalMsg
    | AuthAuthError Http.Error
    | NavMsg Navbar.Messages.NavbarMsg
    | FetchVersion
    | FetchVersionRequest (Result Http.Error String)
    | CloneRequest (Result Http.Error String)
    | ToAdmin
    | ToHome
    | ToAdd
    | Clone
    | Repo String
    | Alert AlertifyConfig
    | LocationChange Location
