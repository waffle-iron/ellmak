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
import Repo.Model exposing (Reference, Repository)
import RightPanel.Updates exposing (update)
import Routing.Router exposing (..)
import Task exposing (perform)
import Uuid
import WebSocket


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


messageEncoder : BaseModel -> String -> Encode.Value
messageEncoder model message =
    let
        uuidStr =
            case model.uuid of
                Just uuid ->
                    (Uuid.toString uuid)

                Nothing ->
                    ""
    in
        Encode.object
            [ ( "token", Encode.string model.authentication.token )
            , ( "username", Encode.string model.authentication.username )
            , ( "uuid", Encode.string uuidStr )
            , ( "msg", Encode.string message )
            ]


repoSuffix : String
repoSuffix =
    "/repo"


remoteEncoder : String -> Encode.Value
remoteEncoder branch =
    Encode.object
        [ ( "ref", Encode.string branch )
        , ( "lastUpdated", Encode.float 0 )
        ]


repoEncoder : LeftPanel -> String -> Encode.Value
repoEncoder model username =
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
            , ( "refs", Encode.list (List.map remoteEncoder model.branches) )
            , ( "frequency", Encode.string model.frequency )
            , ( "shortName", Encode.string model.shortName )
            , ( "username", Encode.string username )
            ]


remoteDecoder : Decoder Reference
remoteDecoder =
    map2 Reference
        (field "ref" Decode.string)
        (field "lastUpdated" Decode.float)


repoDecoder : Decoder Repository
repoDecoder =
    map4 Repository
        (field "remotes" (Decode.dict Decode.string))
        (field "refs" (Decode.list remoteDecoder))
        (field "frequency" Decode.string)
        (field "shortName" Decode.string)


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
                , body = Http.jsonBody <| repoEncoder leftPanelModel model.authentication.username
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
                , url = (model.baseUrl ++ repoSuffix ++ "?username=" ++ model.authentication.username)
                , body = Http.emptyBody
                , expect = Http.expectJson reposDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send GetRepoResult request


refreshDecoder : Decoder String
refreshDecoder =
    field "id_token" Decode.string


refreshEncoder : BaseModel -> Encode.Value
refreshEncoder model =
    Encode.object
        [ ( "token", Encode.string model.authentication.token )
        , ( "username", Encode.string model.authentication.username )
        ]


refreshToken : BaseModel -> Cmd BaseMsg
refreshToken model =
    let
        request =
            Http.request
                { method = "PUT"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.authentication.token)) ]
                , url = (model.baseUrl ++ "/auth")
                , body = Http.jsonBody <| refreshEncoder model
                , expect = Http.expectJson refreshDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send RefreshTokenResult request


sendMessage : String -> Cmd BaseMsg
sendMessage message =
    Task.perform SendWsMessage <| Task.succeed message


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
                    showAlert model "error" (Debug.log "Error" (toString err))

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

        RefreshTokenResult result ->
            case result of
                Ok newToken ->
                    let
                        { authentication } =
                            model

                        newAuthentication =
                            { authentication | token = newToken }

                        newModel =
                            { model | authentication = newAuthentication }
                    in
                        ( newModel, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

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
            ( model, Cmd.batch [ getRepos model, sendMessage "authenticated" ] )

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
            let
                blah =
                    Debug.log "Message" (decodeString Decode.string message)
            in
                ( model, Cmd.none )

        SendWsMessage message ->
            ( model, WebSocket.send model.wsBaseUrl <| encode 0 <| messageEncoder model message )

        Heartbeat newTime ->
            ( model, WebSocket.send model.wsBaseUrl <| encode 0 <| messageEncoder model "heartbeat" )

        RefreshRequest newTime ->
            ( model, refreshToken model )
