module Base.Init exposing (init)

import Auth.Updates exposing (authenticatedCmd)
import Base.Model exposing (..)
import Base.Messages exposing (..)
import Base.Updates exposing (fetchVersionCmd)
import Routing.Router exposing (..)

authVersionCmd : BaseModel -> Cmd BaseMsg
authVersionCmd model =
  Cmd.batch
    [ Cmd.map AuthMsg (authenticatedCmd model.authModel)
    , fetchVersionCmd model
    ]

init : Maybe BaseFlags -> Result String Route -> ( BaseModel, Cmd BaseMsg )
init flags result =
  let
    currentRoute = routeFromResult result
    model = modelFromFlags flags currentRoute
  in
    ( model, authVersionCmd model )
