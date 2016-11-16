module Base.Init exposing (init, locationToMsg)

import Auth.Updates exposing (authenticatedCmd)
import Base.Model exposing (..)
import Base.Messages exposing (..)
import Base.Updates exposing (fetchVersion, translator)
import Navigation exposing (Location)
import Routing.Router exposing (..)


authVersionCmd : BaseModel -> Cmd BaseMsg
authVersionCmd model =
    Cmd.batch
        [ Cmd.map translator (authenticatedCmd model.authModel)
        , fetchVersion model
        ]


locationToMsg : Navigation.Location -> BaseMsg
locationToMsg location =
    LocationChange location


init : Maybe BaseFlags -> Location -> ( BaseModel, Cmd BaseMsg )
init flags location =
    let
        currentRoute =
            routeFromMaybe <| hashParser location

        model =
            modelFromFlags flags currentRoute
    in
        ( model, authVersionCmd model )
