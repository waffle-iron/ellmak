port module Ports exposing (..)

import Model exposing (Model)

port storeModel : Model -> Cmd msg
port removeModel : Model -> Cmd msg
