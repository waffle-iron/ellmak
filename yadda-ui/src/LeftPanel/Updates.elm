module LeftPanel.Updates exposing (..)

import Http exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import LeftPanel.Messages exposing (LeftPanelMsg(..))
import LeftPanel.Model exposing (LeftPanel)
import Navigation exposing (newUrl)
import String exposing (split)


repoSuffix : String
repoSuffix =
    "/repo"


repoEncoder : LeftPanel -> Encode.Value
repoEncoder model =
    Encode.object
        [ ( "url", Encode.string model.repoUrl )
        , ( "branches", Encode.list (List.map Encode.string model.branches) )
        , ( "frequency", Encode.string model.frequency )
        ]


repoDecoder : Decoder String
repoDecoder =
    field "repo" Decode.string


addRepo : LeftPanel -> Cmd LeftPanelMsg
addRepo model =
    let
        request =
            Http.request
                { method = "POST"
                , headers = [ (Http.header "Authorization" ("Bearer " ++ model.token)) ]
                , url = (model.baseUrl ++ repoSuffix)
                , body = Http.jsonBody <| repoEncoder model
                , expect = Http.expectJson repoDecoder
                , timeout = Nothing
                , withCredentials = True
                }
    in
        Http.send PostRepoResult request


update : LeftPanelMsg -> LeftPanel -> ( LeftPanel, Cmd LeftPanelMsg )
update msg model =
    case msg of
        ToHome ->
            ( model, newUrl ("#") )

        Eat ->
            ( model, Cmd.none )

        ClickAddRepo ->
            ( model, addRepo model )

        SetRepoUrl repoUrl ->
            ( { model | repoUrl = repoUrl }, Cmd.none )

        SetBranches branchStr ->
            let
                branches =
                    split "\n" branchStr
            in
                ( { model | branches = branches }, Cmd.none )

        SetFrequency frequency ->
            ( { model | frequency = frequency }, Cmd.none )

        SetShortName shortName ->
            ( { model | shortName = shortName }, Cmd.none )

        PostRepoResult result ->
            case result of
                Ok result ->
                    ( model |> Debug.log result, Cmd.none )

                Err error ->
                    ( model |> Debug.log (toString error), Cmd.none )
