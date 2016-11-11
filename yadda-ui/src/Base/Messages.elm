module Base.Messages exposing (..)

import Auth.Messages exposing (..)
import Http
import Navbar.Messages exposing (..)
import Notify.Messages exposing (..)

type BaseMsg
  = Show
  | AuthMsg Auth.Messages.Msg
  | NavMsg Navbar.Messages.NavbarMsg
  | NotifyMsg Notify.Messages.Msg
  | FetchVersion
  | FetchVersionSuccess String
  | HttpError Http.Error
  | ToAdmin
  | ToHome
