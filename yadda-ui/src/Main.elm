module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import String exposing (..)
import Task exposing (Task)

main : Program Never
main =
  Html.program
    { init = init
    , update = update
    , subscriptions = \_ -> Sub.none
    , view = view
    }

type alias Model =
  { quote: String
  , username: String
  , password: String
  , token: String
  , errorMsg: String
  }

init : (Model, Cmd Msg)
init =
  (Model "" "" "" "" "", fetchRandomQuoteCmd)

api : String
api =
  "/api/v1"

randomQuoteUrl : String
randomQuoteUrl =
  api ++ "/quotes"

registerUrl : String
registerUrl =
  api ++ "/users"

loginUrl : String
loginUrl =
  api ++ "sessions/create"

fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
  Http.getString randomQuoteUrl

fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
  Task.perform HttpError FetchQuoteSuccess fetchRandomQuote

userEncoder : Model -> Encode.Value
userEncoder model =
  Encode.object
    [ ("username", Encode.string model.username)
    , ("password", Encode.string model.password)
    ]

authUser : Model -> String -> Task Http.Error String
authUser model apiUrl =
  { verb = "POST"
  , headers = [ ("Content-Type", "application/json" ) ]
  , url = apiUrl
  , body = Http.string <| Encode.encode 0 <| userEncoder model
  }
  |> Http.send Http.defaultSettings
  |> Http.fromJson tokenDecoder

authUserCmd : Model -> String -> Cmd Msg
authUserCmd model apiUrl =
  Task.perform AuthError GetTokenSuccess <| authUser model apiUrl

tokenDecoder : Decoder String
tokenDecoder =
  "id_token" := Decode.string

type Msg
  = GetQuote
  | FetchQuoteSuccess String
  | HttpError Http.Error
  | AuthError Http.Error
  | SetUsername String
  | SetPassword String
  | ClickRegisterUser
  | ClickLogin
  | Logout
  | GetTokenSuccess String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetQuote ->
      ( model, fetchRandomQuoteCmd )
    FetchQuoteSuccess newQuote ->
      ( { model | quote = newQuote }, Cmd.none )
    HttpError _ ->
      ( model, Cmd.none )
    AuthError error ->
      ( { model | errorMsg = (toString error) }, Cmd.none )
    SetUsername username ->
      ( { model | username = username }, Cmd.none )
    SetPassword password ->
      ( { model | password = password }, Cmd.none )
    ClickRegisterUser ->
      ( model, authUserCmd model registerUrl )
    ClickLogin ->
      ( model, authUserCmd model loginUrl )
    Logout ->
      ( { model | username = "", token = "" }, Cmd.none )
    GetTokenSuccess newToken ->
      ( { model | token = newToken, password = "", errorMsg = "" } |> Debug.log "got new token", Cmd.none )

view : Model -> Html Msg
view model =
  let
    -- Is the user logged in?
    loggedIn : Bool
    loggedIn =
      if String.length model.token > 0 then True else False

    -- If the user is logged in, show a greeting; If not, show the login/registration.
    authBoxView =
      let
        -- If there is an error on authentication, show the error alert
        showError : String
        showError =
          if String.isEmpty model.errorMsg then "hidden" else ""

        -- Greet a logged in user by username
        greeting : String
        greeting =
          "Hello, " ++ model.username ++ "!"
      in
        if loggedIn then
          div [id "greeting"] [
            h3 [ class "text-center" ] [ text greeting ]
            , p [ class "text-center" ] [ text "You have super-secret access to protected quotes."]
            , p [ class "text-center" ] [
              button [ class "btn btn-danger", onClick Logout ] [ text "Logout"]
            ]
          ]
        else
          div [ id "form" ] [
            h2 [ class "text-center" ] [ text "Login or Register"]
            , p [ class "help-block" ] [ text "If you already have an account, please login.  Otherwise, enter your desired username/password and register."]
            , div [ class showError ] [
              div [ class "alert alert-danger" ] [ text model.errorMsg ]
            ]
            , div [ class "form-group row" ] [
              div [ class "col-md-offset-2 col-md-8" ] [
                label [ for "username" ] [ text "Username: " ]
                , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
              ]
            ]
            , div [ class "form-group row"] [
              div [ class "col-md-offset-2 col-md-8" ] [
                label [ for "password" ] [text "Password: " ]
                , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
              ]
            ]
            , div [ class "text-center"] [
              button [ class "btn btn-primary", onClick ClickLogin ] [ text "Login" ] 
              , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register"]
            ]
          ]
  in
    div [ class "container" ] [
      h2 [ class "text-center" ] [ text "Yadda: Repository Tracking" ]
      , p [ class "text-center"] [
        button [ class "btn btn-success", onClick GetQuote ] [ text "Track a Repository" ]
        ]
      , blockquote [] [
        p [] [text model.quote]
      ]
      , div [ class "jumbotron text-left" ] [
        -- Login/Register form or user greeting
        authBoxView
      ]
    ]
