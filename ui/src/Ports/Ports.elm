port module Ports.Ports exposing (..)

import Base.Model exposing (AlertifyConfig)
import Flags.Flags exposing (Flags)


port storeFlags : Flags -> Cmd msg


port removeFlags : Flags -> Cmd msg


port alertify : AlertifyConfig -> Cmd msg
