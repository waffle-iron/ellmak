module Conversions.Model exposing (..)

import Base.Model exposing (BaseModel)
import Conversions.Environment exposing (toString)
import Conversions.Route exposing (toString)
import Flags.Flags exposing (Flags)


toFlags : BaseModel -> Flags
toFlags model =
    let
        { env, baseUrl, wsBaseUrl, apiVersion, uiVersion, authentication, leftPanel, rightPanel } =
            model

        { route } =
            leftPanel

        { username, token, payload } =
            authentication

        { expiry } =
            payload
    in
        Flags
            (Conversions.Environment.toString env)
            0
            baseUrl
            wsBaseUrl
            apiVersion
            uiVersion
            username
            token
            expiry
            (Conversions.Route.toString route)
