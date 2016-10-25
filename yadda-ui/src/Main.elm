module Main exposing (..)

import Html exposing (..)
import Html.App exposing (map, program)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
-- import Http
-- import Http.Decorators
import Auth.Messages exposing (..)
import Auth.Model exposing (..)
import Auth.Updates exposing (..)
import Auth.View exposing (..)
-- import Json.Decode as Decode exposing (..)
-- import Json.Encode as Encode exposing (..)
import String exposing (..)
-- import Task exposing (Task)

main : Program Never
main =
  Html.App.program
    { init = init
    , update = update
    , subscriptions = \_ -> Sub.none
    , view = view
    }

type alias Model =
  { authModel: Authentication
  }

init : (Model, Cmd Msg)
init =
  (Model Auth.Model.new, Cmd.none)

-- randomQuoteUrl : String
-- randomQuoteUrl =
--   api ++ "/quotes"
--
-- protectedQuoteUrl : String
-- protectedQuoteUrl =
--   api ++ "/protected/quotes"
--
-- registerUrl : String
-- registerUrl =
--   api ++ "/users"
--
-- loginUrl : String
-- loginUrl =
--   api ++ "sessions/create"
--
-- fetchRandomQuote : Platform.Task Http.Error String
-- fetchRandomQuote =
--   Http.getString randomQuoteUrl
--
-- fetchRandomQuoteCmd : Cmd Msg
-- fetchRandomQuoteCmd =
--   Task.perform HttpError FetchQuoteSuccess fetchRandomQuote
--
-- fetchProtectedQuote : Model -> Task Http.Error String
-- fetchProtectedQuote model =
--   { verb = "GET"
--   , headers = [ ("Authorization", "Bearer " ++ model.loginModel.token ) ]
--   , url = protectedQuoteUrl
--   , body = Http.empty
--   }
--   |> Http.send Http.defaultSettings
--   |> Http.Decorators.interpretStatus
--   |> Task.map responseText
--
-- fetchProtectedQuoteCmd : Model -> Cmd Msg
-- fetchProtectedQuoteCmd model =
--   Task.perform HttpError FetchProtectedQuoteSuccess <| fetchProtectedQuote model

-- responseText : Http.Response -> String
-- responseText response =
--   case response.value of
--     Http.Text t ->
--       t
--     _ ->
--       ""

-- userEncoder : Model -> Encode.Value
-- userEncoder model =
--   Encode.object
--     [ ("username", Encode.string model.username)
--     , ("password", Encode.string model.password)
--     ]
--
-- authUser : Model -> String -> Task Http.Error String
-- authUser model apiUrl =
--   { verb = "POST"
--   , headers = [ ("Content-Type", "application/json" ) ]
--   , url = apiUrl
--   , body = Http.string <| Encode.encode 0 <| userEncoder model
--   }
--   |> Http.send Http.defaultSettings
--   |> Http.fromJson tokenDecoder
--
-- authUserCmd : Model -> String -> Cmd Msg
-- authUserCmd model apiUrl =
--   Task.perform AuthError GetTokenSuccess <| authUser model apiUrl
--
-- tokenDecoder : Decoder String
-- tokenDecoder =
--   "id_token" := Decode.string

type Msg
  = AuthMsg Auth.Messages.Msg
  | Logout

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AuthMsg subMsg ->
      let
        ( updatedLoginModel, loginCmd ) =
          Auth.Updates.update subMsg model.authModel
      in
        ( { model | authModel = updatedLoginModel }, Cmd.map AuthMsg loginCmd )
    Logout ->
      ( model, Cmd.none )

view : Model -> Html Msg
view model =
  let
    -- Is the user logged in?
    loggedIn : Bool
    loggedIn =
      if String.length model.authModel.token > 0 then True else False

    -- Greet a logged in user by username
    greeting : String
    greeting =
      "Hello, " ++ model.authModel.username ++ "!"

    homeView =
      if loggedIn then
        div [] [
          div [id "greeting"] [
            h3 [ class "text-center" ] [ text greeting ]
            , p [ class "text-center" ] [ text "You have super-secret access to protected quotes."]
            , p [ class "text-center" ] [
              button [ class "btn btn-danger", onClick Logout ] [ text "Logout"]
            ]
          ]
        ]
      else
        div [] [ Html.App.map AuthMsg ( Auth.View.view model.authModel ) ]
  in
    div [ class "container" ] [
      h2 [ class "text-center" ] [ text "Yadda: Repository Tracking" ]
      , homeView
    ]
