module Base.Subscriptions exposing (..)

import Base.Model exposing (BaseModel)
import Base.Messages exposing (..)
import Time exposing (Time, minute)
import WebSocket


subscriptions : BaseModel -> Sub BaseMsg
subscriptions model =
    Sub.batch [ Time.every minute Tick, Time.every (5 * minute) FiveMinute, WebSocket.listen model.wsBaseUrl NewMessage ]
