module Auth.Messages exposing (..)

import Auth.Model exposing (JwtPayload)
import Http
import Jwt exposing (JwtError)


type InternalMsg
    = Authenticated Bool
    | DecodeResult (Result JwtError JwtPayload)
    | Login
    | Logout
    | SetPassword String
    | SetUsername String
    | AuthUserResult (Result Http.Error String)


type ExternalMsg
    = AuthError Http.Error


type Msg
    = ForSelf InternalMsg
    | ForParent ExternalMsg


type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onAuthError : Http.Error -> msg
    }


type alias Translator parentMsg =
    Msg -> parentMsg


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onAuthError } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (AuthError error) ->
            onAuthError error
