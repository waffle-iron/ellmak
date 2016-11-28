module Base.Updates exposing (..)

import Auth.Messages exposing (..)
import Auth.Model exposing (AuthError(..))
import Auth.Updates exposing (authenticated)
import Base.Messages exposing (..)
import Base.Model exposing (..)
import Conversions.Model exposing (toFlags)
import Dict exposing (toList)
import Http exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Jwt exposing (JwtError(TokenProcessingError, TokenDecodeError))
import LeftPanel.Messages exposing (Translator, translator)
import LeftPanel.Model exposing (LeftPanel)
import LeftPanel.Updates exposing (update)
import Navigation exposing (..)
import Navbar.Updates exposing (..)
import Ports.Ports exposing (alertify, storeFlags)
import Repo.Model exposing (Repository)
import RightPanel.Updates exposing (update)
import Routing.Router exposing (..)
import WebSocket


checkAuthExpiry : BaseModel -> Cmd BaseMsg
checkAuthExpiry model =
    Cmd.map authTranslator (authenticated model.authentication)


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


authTranslator : Auth.Messages.Translator BaseMsg
authTranslator =
    Auth.Messages.translator { onInternalMessage = AuthMsg, onAuthSuccess = AuthSuccess, onAuthError = AuthError }


leftPanelTranslator : LeftPanel.Messages.Translator BaseMsg
leftPanelTranslator =
    LeftPanel.Messages.translator { onInternalMessage = LeftPanelMsg, onPostRepo = Base.Messages.PostRepo, onSendWsMessage = SendWsMessage }


checkExpiry : BaseModel -> Cmd BaseMsg
checkExpiry model =
    Cmd.map authTranslator (authenticated model.authentication)


repoSuffix : String
repoSuffix =
    "/repo"


repoEncoder : LeftPanel -> Encode.Value
repoEncoder model =
    let
        additionalRemotesValues =
            Dict.values model.addRemotesDict

        remotesToAppend =
            Dict.fromList additionalRemotesValues

        allRemotes =
            Dict.union model.remotesDict remotesToAppend
    in
        Encode.object
            [ ( "remotes", Encode.object <| Dict.toList <| Dict.map (\k v -> Encode.string v) allRemotes )
            , ( "branches", Encode.list (List.map Encode.string model.branches) )
            , ( "frequency", Encode.string model.frequency )
            , ( "shortName", Encode.string model.shortName )
            ]


repoDecoder : Decoder Repository
repoDecoder =
    map4 Repository
        (at [ "remotes" ] (Decode.dict Decode.string))
        (at [ "branches" ] (Decode.list Decode.string))
        (at [ "frequency" ] Decode.string)
        (at [ "shortName" ] Decode.string)


reposDecoder : Decoder (List Repository)
reposDecoder =
    Decode.list repoDecoder


addRepo : BaseModel -> LeftPanel -> Cmd BaseMsg
addRepo model leftPanelModel =
    let
        request =
            Http.request
                { method = "POST"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.authentication.token)) ]
                , url = (model.baseUrl ++ repoSuffix)
                , body = Http.jsonBody <| repoEncoder leftPanelModel
                , expect = Http.expectJson repoDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send PostRepoResult request


getRepos : BaseModel -> Cmd BaseMsg
getRepos model =
    let
        request =
            Http.request
                { method = "GET"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.authentication.token)) ]
                , url = (model.baseUrl ++ repoSuffix)
                , body = Http.emptyBody
                , expect = Http.expectJson reposDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send GetRepoResult request


update : BaseMsg -> BaseModel -> ( BaseModel, Cmd BaseMsg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Alert config ->
            ( model, alertCmd config )

        Repo repo ->
            showAlert model "success" repo

        CloneRequest result ->
            case result of
                Ok success ->
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
                ( newModel, Cmd.batch [ storeFlags newModel, Cmd.map leftPanelTranslator leftPanelCmd ] )

        PostRepo leftPanelModel ->
            ( model, addRepo model leftPanelModel )

        PostRepoResult result ->
            case result of
                Ok success ->
                    let
                        rightPanel =
                            model.rightPanel

                        repos =
                            rightPanel.repos

                        newRightPanel =
                            { rightPanel | repos = Dict.insert success.shortName success repos }

                        newLeftPanel =
                            LeftPanel.Model.defaultLeftPanel

                        newModel =
                            { model | rightPanel = newRightPanel, leftPanel = newLeftPanel }
                    in
                        ( newModel, newUrl "#" )

                Err err ->
                    showAlert model "error" (toString err)

        GetRepoResult result ->
            case result of
                Ok success ->
                    let
                        rightPanel =
                            model.rightPanel

                        repos =
                            rightPanel.repos

                        newRightPanel =
                            { rightPanel | repos = Dict.fromList <| List.map (\x -> ( x.shortName, x )) success }

                        newModel =
                            { model | rightPanel = newRightPanel }
                    in
                        ( newModel, Cmd.none )

                Err err ->
                    showAlert model "error" (toString err)

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
                ( newModel, Cmd.batch [ storeFlags newModel, Cmd.map authTranslator authCmd ] )

        AuthSuccess ->
            ( model, getRepos model )

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

        NewMessage message ->
            ( model |> Debug.log message, Cmd.none )

        SendWsMessage message ->
            ( model, WebSocket.send model.wsBaseUrl message )

        Tick newTime ->
            ( model, WebSocket.send model.wsBaseUrl "heartbeat" )
