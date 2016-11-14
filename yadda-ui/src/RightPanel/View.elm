module RightPanel.View exposing (..)

import Base.Model exposing (..)
import Base.Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

panelContent : String -> List (Html a) -> Html a
panelContent heading body =
  div [ class "panel panel-default"] [
    div [ class "panel-heading" ] [ text heading ]
    , div [ class "panel-body" ] body
  ]

view : BaseModel -> Html BaseMsg
view model =
  let
    baseConfig = Base.Model.newConfig
    config = { baseConfig | message = "Testing!!!" }
  in
    panelContent "Repository Management" [
      div [ class "row" ] [
        div [ class "col-lg-6 col-lg-offset-6" ] [
          button [ class "btn btn-default btn-block", onClick ToAdd ] [ text "Add" ]
        ]
      ]
      , div [ class "row" ] [
        div [ class "col-lg-12" ] [
          div [ class "panel-group", id "right-accordion" ] [
            div [ class "panel panel-default" ] [
              div [ class "panel-heading", onClick <| Alert config ] [ text "One" ]
              , div [ class "panel-body panel-collapse collapse", id "collapseOne" ] [ text "One" ]
            ]
            , div [ class "panel panel-default" ] [
              div [ class "panel-heading", onClick (Repo "Two") ] [ text "Two" ]
              , div [ class "panel-body panel-collapse collapse" ] [ text "Two" ]
            ]
          ]
        ]
      ]
    ]
