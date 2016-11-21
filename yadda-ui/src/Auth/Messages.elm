module Auth.Messages exposing (..)

import Auth.Model exposing (AuthError, JwtPayload)
import Http exposing (Error)
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
    = AuthenticationError AuthError
    | AuthenticationSuccess


type Msg
    = ForSelf InternalMsg
    | ForParent ExternalMsg


type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onAuthError : AuthError -> msg
    , onAuthSuccess : msg
    }


type alias Translator parentMsg =
    Msg -> parentMsg


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onAuthSuccess, onAuthError } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent AuthenticationSuccess ->
            onAuthSuccess

        ForParent (AuthenticationError error) ->
            onAuthError error
