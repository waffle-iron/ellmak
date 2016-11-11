module Navbar.Updates exposing (..)

import Auth.Updates exposing (logout)
import Base.Model exposing (BaseModel)
import Navbar.Messages exposing (..)

update : NavbarMsg -> BaseModel -> ( BaseModel, Cmd NavbarMsg )
update message model =
  case message of
    Logout ->
      let
        ( nam, _ ) = logout model.authModel
        newModel = { model | authModel = nam }
      in
        ( newModel, Cmd.none )
