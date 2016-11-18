module RightPanel.Model exposing (..)


type alias RightPanel =
    { repos : String
    }


defaultRightPanel : RightPanel
defaultRightPanel =
    { repos = ""
    }
