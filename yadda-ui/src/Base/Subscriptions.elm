module Base.Subscriptions exposing (..)

import Base.Model exposing (BaseModel)
import Base.Messages exposing (..)


subscriptions : BaseModel -> Sub BaseMsg
subscriptions _ =
    Sub.none
