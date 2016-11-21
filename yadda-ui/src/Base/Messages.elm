module Base.Messages exposing (..)

import Auth.Model exposing (AuthError)
import Auth.Messages exposing (InternalMsg)
import Base.Model exposing (AlertifyConfig)
import Http
import LeftPanel.Messages exposing (InternalMsg)
import LeftPanel.Model exposing (LeftPanel)
import Navbar.Messages exposing (..)
import Navigation exposing (Location)
import Repo.Model exposing (Repository)
import RightPanel.Messages exposing (RightPanelMsg)


type BaseMsg
    = -- Parent to Child Messages
      AuthMsg Auth.Messages.InternalMsg
    | LeftPanelMsg LeftPanel.Messages.InternalMsg
    | NavMsg Navbar.Messages.NavbarMsg
    | RightPanelMsg RightPanel.Messages.RightPanelMsg
      -- Child to Parent Messages
    | AuthError Auth.Model.AuthError
    | AuthSuccess
    | PostRepo LeftPanel.Model.LeftPanel
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
    | PostRepoResult (Result Http.Error Repository)
    | GetRepoResult (Result Http.Error (List Repository))
