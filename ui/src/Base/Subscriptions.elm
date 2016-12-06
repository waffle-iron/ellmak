module Base.Subscriptions exposing (..)

import Auth.Subscriptions exposing (subscriptions)
import Base.Model exposing (BaseModel)
import Base.Messages exposing (..)
import Time exposing (Time, minute)
import WebSocket


heartbeat : Sub BaseMsg
heartbeat =
    Time.every minute Heartbeat


webSocketListener : BaseModel -> Sub BaseMsg
webSocketListener model =
    WebSocket.listen model.wsBaseUrl NewMessage


subscriptions : BaseModel -> Sub BaseMsg
subscriptions model =
    Sub.batch
        [ heartbeat
        , webSocketListener model
        , Sub.map AuthMsg (Auth.Subscriptions.subscriptions model.authentication)
        ]
