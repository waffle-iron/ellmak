module Base.Messages exposing (..)

import Auth.Model exposing (AuthError)
import Auth.Messages exposing (InternalMsg)
import Base.Model exposing (AlertifyConfig)
import Http
import LeftPanel.Messages exposing (LeftPanelMsg)
import Navbar.Messages exposing (..)
import Navigation exposing (Location)
import RightPanel.Messages exposing (RightPanelMsg)


type BaseMsg
    = -- Parent to Child Messages
      AuthMsg InternalMsg
    | LeftPanelMsg LeftPanel.Messages.LeftPanelMsg
    | NavMsg Navbar.Messages.NavbarMsg
    | RightPanelMsg RightPanel.Messages.RightPanelMsg
      -- Child to Parent Messages
    | AuthError Auth.Model.AuthError
      -- Navigation Messages
    | LocationChange Location
    | ToHome
    | ToAdd
      -- UI Messages
    | Alert AlertifyConfig
    | Clone
    | Repo String
    | Eat
    | NoOp
      -- API Messages
    | CloneRequest (Result Http.Error String)
