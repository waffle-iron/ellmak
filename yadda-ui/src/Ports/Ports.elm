port module Ports.Ports exposing (..)

import Base.Model exposing (BaseFlags)

port storeFlags : BaseFlags -> Cmd msg
port removeFlags : BaseFlags -> Cmd msg
