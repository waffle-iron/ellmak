module LeftPanel.Messages exposing (..)

import LeftPanel.Model exposing (LeftPanel)


type InternalMsg
    = -- UI Messages
      Eat
    | NewRemoteRow String
      -- Navigation Messages
    | ToHome
      -- Input Messages
    | ClickAddRepo
    | ClickSendMessage
    | SetOriginRemote String
    | SetAdditionalRepoKey Int String
    | SetAdditionalRepoValue Int String
    | SetBranches String
    | SetFrequency String
    | SetShortName String


type ExternalMsg
    = PostRepo LeftPanel
    | SendWsMessage String


type Msg
    = ForSelf InternalMsg
    | ForParent ExternalMsg


type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onPostRepo : LeftPanel -> msg
    , onSendWsMessage : String -> msg
    }


type alias Translator parentMsg =
    Msg -> parentMsg


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onPostRepo, onSendWsMessage } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (PostRepo model) ->
            onPostRepo model

        ForParent (SendWsMessage message) ->
            onSendWsMessage message
