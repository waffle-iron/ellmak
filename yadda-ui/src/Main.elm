module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
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
  }

init : (Model, Cmd Msg)
init =
  (Model "", fetchRandomQuoteCmd)

api : String
api =
  "/api/v1"

randomQuoteUrl : String
randomQuoteUrl =
  api

fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
  Http.getString randomQuoteUrl

fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
  Task.perform HttpError FetchQuoteSuccess fetchRandomQuote

type Msg
  = GetQuote
  | FetchQuoteSuccess String
  | HttpError Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetQuote ->
      ( model, fetchRandomQuoteCmd )
    FetchQuoteSuccess newQuote ->
      ( { model | quote = newQuote }, Cmd.none )
    HttpError _ ->
      ( model, Cmd.none )

view : Model -> Html Msg
view model =
  div [ class "container" ] [
    h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
    , p [ class "text-center"] [
      button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote" ]
    ]
    , blockquote [] [
      p [] [text model.quote]
    ]
  ]
