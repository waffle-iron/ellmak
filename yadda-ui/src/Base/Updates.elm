module Base.Updates exposing (..)

import Auth.Messages exposing (..)
import Auth.Updates exposing (logout)
import Base.Messages exposing (..)
import Base.Model exposing (modelToFlags, BaseModel)
import Http
import Json.Decode as Decode exposing (..)
import Navigation exposing (..)
import Navbar.Updates exposing (..)
import Notify.Updates exposing (show)
import Ports.Ports exposing (storeFlags)
import Routing.Router exposing (..)
import Task exposing (..)

versionDecoder : Decoder String
versionDecoder =
  "version" := Decode.string

fetchVersion : BaseModel -> Task Http.Error String
fetchVersion model =
  { verb = "GET"
  , headers = [ ("Authorization", "Bearer " ++ model.authModel.token ) ]
  , url = model.baseUrl
  , body = Http.empty
  }
  |> Http.send Http.defaultSettings
  |> Http.fromJson versionDecoder

fetchVersionCmd : BaseModel -> Cmd BaseMsg
fetchVersionCmd model =
  Task.perform HttpError FetchVersionSuccess <| fetchVersion model

storeModelCmd : BaseModel -> Cmd BaseMsg
storeModelCmd model =
  modelToFlags model |> storeFlags

showNotification : BaseModel -> String -> String -> ( BaseModel, Cmd BaseMsg )
showNotification model level message =
  let
    notifyModel = model.notifyModel
    ( nnm, ncmd ) = show { notifyModel | level = level, message = message }
    newModel = { model | notifyModel = nnm }
  in
    ( newModel, Cmd.batch [ storeModelCmd newModel, Cmd.map NotifyMsg ncmd ] )

update : BaseMsg -> BaseModel -> ( BaseModel, Cmd BaseMsg )
update msg model =
  case msg of
    Show ->
      showNotification model "success" "Success!"

    HttpError err ->
      ( model , Cmd.none )

    FetchVersion ->
      ( model, fetchVersionCmd model )

    FetchVersionSuccess apiVersion ->
      let
        newModel = { model | apiVersion = apiVersion }
      in
        ( newModel, storeModelCmd newModel )

    AuthMsg subMsg ->
      case subMsg of
        AuthError err ->
          showNotification model "danger" "Unable to login, please try again."
        _ ->
          let
            ( updatedAuthModel, authCmd ) = Auth.Updates.update subMsg model.authModel model.baseUrl
            newModel = { model | authModel = updatedAuthModel }
          in
            ( newModel, Cmd.batch [ storeModelCmd newModel,  Cmd.map AuthMsg authCmd ] )

    NotifyMsg subMsg ->
      let
        ( unm, ncmd ) = Notify.Updates.update subMsg model.notifyModel
        newModel = { model | notifyModel = unm }
      in
        ( newModel , Cmd.batch [ storeModelCmd newModel, Cmd.map NotifyMsg ncmd ] )

    NavMsg subMsg ->
      let
        ( unm, ncmd ) = Navbar.Updates.update subMsg model
      in
        ( unm , Cmd.batch [ storeModelCmd unm, Cmd.map NavMsg ncmd ] )

    ToAdmin ->
        ( model, Navigation.newUrl ( "#admin" ) )

    ToHome ->
        ( model, Navigation.newUrl ( "#" ) )

urlUpdate : Result String Route -> BaseModel -> ( BaseModel, Cmd BaseMsg )
urlUpdate result model =
    let
        currentRoute = routeFromResult result
        newModel = { model | route = currentRoute } |> Debug.log (toString currentRoute)
    in
        ( newModel, storeModelCmd newModel )
