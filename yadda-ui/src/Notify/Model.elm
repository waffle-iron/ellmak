module Notify.Model exposing (..)

type alias Notification =
  { message : String
  , level : String
  , hidden : Bool
  }

new : Notification
new =
  { message = ""
  , level = "info"
  , hidden = True
  }
