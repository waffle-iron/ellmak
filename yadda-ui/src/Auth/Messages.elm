module Auth.Messages exposing (..)

type Msg
  = Login
  | Logout
  | SetPassword String
  | SetUsername String
