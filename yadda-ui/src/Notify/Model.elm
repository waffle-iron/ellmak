module Notify.Model exposing (..)

type Level =
  Fatal
  | Error
  | Warn
  | Info
  | Debug
  | Trace

type alias Notification =
  { message : String
  , level : String
  , hidden : Bool
  }

new : Notification
new =
  { message = ""
  , level = toString Info
  , hidden = True
  }
