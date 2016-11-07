module Auth.Messages exposing (..)

import Auth.Model exposing(JwtPayload)
import Http
import Jwt exposing (JwtError)

type Msg
  = AuthError Http.Error
  | DecodeError JwtError
  | GetTokenSuccess String
  | DecodeTokenSuccess JwtPayload
  | Login
  | Logout
  | SetPassword String
  | SetUsername String
