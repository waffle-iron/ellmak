module Main exposing (..)

import Base.Init exposing (init)
import Base.Model exposing (BaseFlags)
import Base.Subscriptions exposing (subscriptions)
import Base.Updates exposing (update, urlUpdate)
import Base.View exposing (view)
import Navigation
import Routing.Router exposing (parser)

main : Program (Maybe BaseFlags)
main =
  Navigation.programWithFlags parser
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    , urlUpdate = urlUpdate
    }
