module Auth.Messages exposing (..)

import Http

type Msg
  = AuthError Http.Error
  | GetTokenSuccess String
  | Login
  | Logout
  | SetPassword String
  | SetUsername String
