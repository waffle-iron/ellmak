module Conversions.Flags exposing (..)

import Auth.Model exposing (Authentication, defaultAuthentication)
import Base.Model exposing (BaseModel, defaultBase)
import Conversions.String exposing (toEnvironment, toRoute)
import Flags.Flags exposing (Flags)
import LeftPanel.Model exposing (defaultLeftPanel)
import Random.Pcg exposing (initialSeed, step)
import RightPanel.Model exposing (defaultRightPanel)
import Routing.Router exposing (Route)
import Uuid exposing (uuidGenerator)


toBaseModel : Maybe Flags -> Route -> BaseModel
toBaseModel maybeFlags route =
    case maybeFlags of
        Nothing ->
            let
                base =
                    defaultBase

                { leftPanel } =
                    base

                newLeftPanel =
                    { leftPanel | route = route }
            in
                { base | leftPanel = newLeftPanel }

        Just flags ->
            let
                ( uuid, _ ) =
                    step uuidGenerator <| initialSeed flags.randomSeed

                rightPanel =
                    defaultRightPanel

                leftPanel =
                    defaultLeftPanel

                newLeftPanel =
                    { leftPanel | route = route }
            in
                BaseModel
                    (toEnvironment flags.env)
                    (Just uuid)
                    flags.baseUrl
                    flags.wsBaseUrl
                    flags.apiVersion
                    flags.uiVersion
                    (toAuthentication flags)
                    newLeftPanel
                    rightPanel


toAuthentication : Flags -> Authentication
toAuthentication flags =
    let
        authentication =
            defaultAuthentication

        { payload } =
            authentication

        newPayload =
            { payload | expiry = flags.expiry }
    in
        { authentication | username = flags.username, token = flags.token, payload = newPayload }
