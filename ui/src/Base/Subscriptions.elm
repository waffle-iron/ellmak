module Base.Subscriptions exposing (..)

import Base.Model exposing (BaseModel)
import Base.Messages exposing (..)
import Time exposing (Time, minute)
import WebSocket


heartbeat : Sub BaseMsg
heartbeat =
    Time.every minute Heartbeat


refreshRequest : Sub BaseMsg
refreshRequest =
    Time.every (5 * minute) RefreshRequest


webSocketListener : BaseModel -> Sub BaseMsg
webSocketListener model =
    WebSocket.listen model.wsBaseUrl NewMessage


subscriptions : BaseModel -> Sub BaseMsg
subscriptions model =
    let
        baseSubs =
            [ heartbeat, webSocketListener model ]

        subs =
            case model.authentication.authenticated of
                True ->
                    refreshRequest :: baseSubs

                False ->
                    baseSubs
    in
        Sub.batch subs
