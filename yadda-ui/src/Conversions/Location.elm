module Conversions.Location exposing (..)

import Base.Messages exposing (BaseMsg(LocationChange))
import Navigation exposing (Location)


toBaseMsg : Location -> BaseMsg
toBaseMsg location =
    LocationChange location
