module Auth.Messages exposing (..)

import Auth.Model exposing (JwtError, JwtPayload)
import Http


type Msg
    = Authenticated Bool
    | DecodeResult (Result JwtError JwtPayload)
    | Login
    | Logout
    | SetPassword String
    | SetUsername String
    | AuthUserResult (Result Http.Error String)
