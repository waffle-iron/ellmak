module Base.Updates exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (AuthError(..))
import Auth.Updates exposing (authenticated)
import Base.Messages exposing (..)
import Base.Model exposing (..)
import Conversions.Model exposing (toFlags)
import Http exposing (..)
import Json.Decode as Decode exposing (..)
import Jwt exposing (JwtError(TokenProcessingError, TokenDecodeError))
import LeftPanel.Updates exposing (update)
import Navigation exposing (..)
import Navbar.Updates exposing (..)
import Ports.Ports exposing (alertify, storeFlags)
import RightPanel.Updates exposing (update)
import Routing.Router exposing (..)


checkAuthExpiry : BaseModel -> Cmd BaseMsg
checkAuthExpiry model =
    Cmd.map translator (authenticated model.authentication)


storeFlags : BaseModel -> Cmd BaseMsg
storeFlags model =
    toFlags model |> Ports.Ports.storeFlags


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


clone : BaseModel -> Cmd BaseMsg
clone model =
    let
        request =
            Http.request
                { method = "GET"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.authentication.token)) ]
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


translator : Auth.Messages.Translator BaseMsg
translator =
    Auth.Messages.translator { onInternalMessage = AuthMsg, onAuthError = AuthError }


checkExpiry : BaseModel -> Cmd BaseMsg
checkExpiry model =
    Cmd.map translator (authenticated model.authentication)


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

        LeftPanelMsg subMsg ->
            let
                ( updatedModel, leftPanelCmd ) =
                    LeftPanel.Updates.update subMsg model.leftPanel

                newModel =
                    { model | leftPanel = updatedModel }
            in
                ( newModel, Cmd.batch [ storeFlags newModel, Cmd.map LeftPanelMsg leftPanelCmd ] )

        RightPanelMsg subMsg ->
            let
                ( updatedModel, rightPanelCmd ) =
                    RightPanel.Updates.update subMsg model.rightPanel

                newModel =
                    { model | rightPanel = updatedModel }
            in
                ( newModel, Cmd.batch [ storeFlags newModel, Cmd.map RightPanelMsg rightPanelCmd ] )

        AuthMsg subMsg ->
            let
                ( updatedAuthModel, authCmd ) =
                    Auth.Updates.update subMsg model.authentication model.baseUrl

                newModel =
                    { model | authentication = updatedAuthModel }
            in
                ( newModel, Cmd.batch [ storeFlags newModel, Cmd.map translator authCmd ] )

        AuthError error ->
            case error of
                HttpError httpError ->
                    case httpError of
                        BadStatus resp ->
                            let
                                message =
                                    (toString resp.status.code)
                                        ++ " "
                                        ++ resp.status.message
                                        ++ ": "
                                        ++ resp.body
                            in
                                showAlert model "error" message

                        BadPayload debug resp ->
                            let
                                message =
                                    (toString resp.status.code)
                                        ++ " "
                                        ++ resp.status.message
                                        ++ ": "
                                        ++ resp.body
                                        ++ ": "
                                        ++ debug
                            in
                                showAlert model "error" message

                        BadUrl url ->
                            let
                                message =
                                    "Bad Url: " ++ url
                            in
                                showAlert model "error" message

                        _ ->
                            showAlert model "error" (toString httpError)

                TokenError tokenError ->
                    case tokenError of
                        TokenProcessingError tpe ->
                            showAlert model "error" tpe

                        TokenDecodeError tde ->
                            showAlert model "error" tde

                        _ ->
                            showAlert model "error" (toString tokenError)

        NavMsg subMsg ->
            let
                ( unm, ncmd ) =
                    Navbar.Updates.update subMsg model
            in
                ( unm, Cmd.batch [ storeFlags unm, Cmd.map NavMsg ncmd ] )

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

                { leftPanel } =
                    model

                newLeftPanel =
                    { leftPanel | route = currentRoute }

                newModel =
                    { model | leftPanel = newLeftPanel }
            in
                ( newModel, storeFlags newModel )

        Eat ->
            ( model, Cmd.none )
