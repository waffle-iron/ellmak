port module Ports.Ports exposing (..)

import Base.Model exposing (AlertifyConfig, BaseFlags)

port storeFlags : BaseFlags -> Cmd msg
port removeFlags : BaseFlags -> Cmd msg
port alertify : AlertifyConfig -> Cmd msg
