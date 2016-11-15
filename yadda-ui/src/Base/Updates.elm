module Base.Updates exposing (..)

import Auth.Updates
import Base.Messages exposing (..)
import Base.Model exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (..)
import Navigation exposing (..)
import Navbar.Updates exposing (..)
import Ports.Ports exposing (alertify, storeFlags)
import Routing.Router exposing (..)


versionDecoder : Decoder String
versionDecoder =
    field "version" Decode.string


fetchVersion : BaseModel -> Cmd BaseMsg
fetchVersion model =
    let
        request =
            Http.request
                { method = "GET"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.authModel.token)) ]
                , url = model.baseUrl
                , body = Http.emptyBody
                , expect = Http.expectJson versionDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send FetchVersionRequest request


storeModelCmd : BaseModel -> Cmd BaseMsg
storeModelCmd model =
    modelToFlags model |> storeFlags


showAlert : BaseModel -> String -> String -> ( BaseModel, Cmd BaseMsg )
showAlert model level message =
    let
        baseConfig =
            Base.Model.newConfig

        config =
            { baseConfig | message = message, logType = level }
    in
        ( model, alertCmd config )


cloneDecoder : Decoder String
cloneDecoder =
    field "clone" Decode.string


errorDecoder : Decoder String
errorDecoder =
    field "message" Decode.string


clone : BaseModel -> Cmd BaseMsg
clone model =
    let
        request =
            Http.request
                { method = "GET"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.authModel.token)) ]
                , url = (model.baseUrl ++ "/clone/?repo=blah")
                , body = Http.emptyBody
                , expect = Http.expectJson cloneDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send CloneRequest request


alertCmd : AlertifyConfig -> Cmd BaseMsg
alertCmd config =
    alertify config


update : BaseMsg -> BaseModel -> ( BaseModel, Cmd BaseMsg )
update msg model =
    case msg of
        Alert config ->
            ( model, alertCmd config )

        Repo repo ->
            showAlert model "success" repo

        CloneRequest result ->
            case result of
                Ok success ->
                    let
                        res =
                            Debug.log <| "CloneSuccess: " ++ (toString success)
                    in
                        ( model, Cmd.none )

                Err err ->
                    showAlert model "error" (toString err)

        FetchVersionRequest result ->
            case result of
                Ok apiVersion ->
                    let
                        newModel =
                            { model | apiVersion = apiVersion }
                    in
                        ( newModel, storeModelCmd newModel )

                Err err ->
                    showAlert model "error" (toString err)

        FetchVersion ->
            ( model, fetchVersion model )

        AuthMsg subMsg ->
            let
                ( updatedAuthModel, authCmd ) =
                    Auth.Updates.update subMsg model.authModel model.baseUrl

                newModel =
                    { model | authModel = updatedAuthModel }
            in
                ( newModel, Cmd.batch [ storeModelCmd newModel, Cmd.map AuthMsg authCmd ] )

        NavMsg subMsg ->
            let
                ( unm, ncmd ) =
                    Navbar.Updates.update subMsg model
            in
                ( unm, Cmd.batch [ storeModelCmd unm, Cmd.map NavMsg ncmd ] )

        ToAdmin ->
            ( model, Navigation.newUrl ("#admin") )

        ToHome ->
            ( model, Navigation.newUrl ("#") )

        ToAdd ->
            ( model, Navigation.newUrl ("#addrepo") )

        Clone ->
            ( model, clone model )

        LocationChange location ->
            let
                currentRoute =
                    routeFromMaybe <| hashParser location

                newModel =
                    { model | route = currentRoute }
            in
                ( newModel, Cmd.none )
