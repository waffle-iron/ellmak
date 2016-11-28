module Base.Model exposing (..)

import Auth.Model exposing (Authentication, defaultAuthentication)
import Env.Env exposing (Environment(Development))
import LeftPanel.Model exposing (LeftPanel, defaultLeftPanel)
import RightPanel.Model exposing (RightPanel, defaultRightPanel)


type alias AlertifyConfig =
    { message : String
    , position : String
    , maxItems : Int
    , closeDelay : Int
    , cloc : Bool
    , logType : String
    }


newConfig : AlertifyConfig
newConfig =
    { message = ""
    , position = "bottom center"
    , maxItems = 2
    , closeDelay = 3000
    , cloc = False
    , logType = "success"
    }


type alias BaseModel =
    { env : Environment
    , baseUrl : String
    , wsBaseUrl : String
    , apiVersion : String
    , uiVersion : String
    , authentication : Authentication
    , leftPanel : LeftPanel
    , rightPanel : RightPanel
    }


defaultBase : BaseModel
defaultBase =
    { env = Development
    , baseUrl = "http://localhost:3000/api/v1"
    , wsBaseUrl = "http://localhost:3000"
    , apiVersion = ""
    , uiVersion = ""
    , authentication = defaultAuthentication
    , leftPanel = defaultLeftPanel
    , rightPanel = defaultRightPanel
    }
