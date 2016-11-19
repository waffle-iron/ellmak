module LeftPanel.Messages exposing (..)

import Http exposing (Error)


type LeftPanelMsg
    = -- UI Messages
      Eat
      -- Navigation Messages
    | ToHome
      -- Input Messages
    | ClickAddRepo
    | SetRepoUrl String
    | SetBranches String
    | SetFrequency String
    | SetShortName String
      -- API Messages
    | PostRepoResult (Result Http.Error String)
