module LeftPanel.View exposing (..)

import Base.Messages exposing (..)
import Base.Model exposing (BaseModel)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Routing.Router exposing (..)

panelContent : String -> List (Html a) -> Html a
panelContent heading body =
  div [ class "panel panel-default"] [
    div [ class "panel-heading" ] [ text heading ]
    , div [ class "panel-body" ] body
  ]

view : BaseModel -> Html BaseMsg
view model =
  case model.route of
    Home ->
      panelContent "Repositories" [
        button [ class "btn btn-default", onClick ToAdmin ] [ text "Admin" ]
      ]
    Admin ->
      panelContent "Admin" [
        button [ class "btn btn-default", onClick Clone ] [ text "Clone" ]
        , button [ class "btn btn-default", onClick ToHome ] [ text "Home" ]
      ]
    AddRepo ->
      panelContent "Add Repository" [
        button [ class "btn btn-default", onClick ToHome ] [ text "Cancel" ]
        , button [ class "btn btn-default" ] [ text "Add" ]
      ]
    NotFound ->
      panelContent "Not Found" [
        h4 [] [ text "The resource you have requested cannot be found" ]
      ]
