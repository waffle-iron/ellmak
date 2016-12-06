module Auth.Subscriptions exposing (..)

import Auth.Messages exposing (InternalMsg(RefreshRequest))
import Auth.Model exposing (Authentication)
import Time exposing (minute, Time)


refreshRequest : Sub InternalMsg
refreshRequest =
    Time.every (5 * minute) RefreshRequest


subscriptions : Authentication -> Sub InternalMsg
subscriptions model =
    let
        baseSubs =
            []

        subs =
            case model.authenticated of
                True ->
                    Debug.log "Authenticed Sub" (refreshRequest :: baseSubs)

                False ->
                    baseSubs
    in
        Sub.batch subs
