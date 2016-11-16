module Auth.Messages exposing (..)

import Auth.Model exposing (JwtPayload)
import Http
import Jwt exposing (JwtError)


type Msg
    = Authenticated Bool
    | DecodeResult (Result JwtError JwtPayload)
    | Login
    | Logout
    | SetPassword String
    | SetUsername String
    | AuthUserResult (Result Http.Error String)
