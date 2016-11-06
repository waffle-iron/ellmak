port module Ports exposing (..)

import Model exposing (Base)

port storeModel : Base -> Cmd msg
port removeModel : Base -> Cmd msg
