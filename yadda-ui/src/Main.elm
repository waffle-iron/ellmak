module Main exposing (..)

import Base.Messages exposing (BaseMsg)
import Base.Model exposing (BaseModel)
import Base.Subscriptions exposing (subscriptions)
import Base.Updates exposing (checkExpiry, update)
import Base.View exposing (view)
import Conversions.Flags exposing (toBaseModel)
import Conversions.Location exposing (toBaseMsg)
import Flags.Flags exposing (Flags)
import Navigation exposing (Location, programWithFlags)
import Routing.Router exposing (hashParser, routeFromMaybe)


init : Maybe Flags -> Location -> ( BaseModel, Cmd BaseMsg )
init flags location =
    let
        model =
            toBaseModel flags << routeFromMaybe <| hashParser location
    in
        ( model, checkExpiry model )


main : Program (Maybe Flags) BaseModel BaseMsg
main =
    programWithFlags toBaseMsg
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
