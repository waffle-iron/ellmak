module Main exposing (..)

import Base.Init exposing (init, locationToMsg)
import Base.Messages exposing (BaseMsg)
import Base.Model exposing (BaseFlags, BaseModel)
import Base.Subscriptions exposing (subscriptions)
import Base.Updates exposing (update)
import Base.View exposing (view)
import Navigation


main : Program (Maybe BaseFlags) BaseModel BaseMsg
main =
    Navigation.programWithFlags locationToMsg
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
