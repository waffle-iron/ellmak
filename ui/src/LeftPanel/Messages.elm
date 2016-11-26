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
    | SetOriginRemote String
    | SetAdditionalRepoKey Int String
    | SetAdditionalRepoValue Int String
    | SetBranches String
    | SetFrequency String
    | SetShortName String


type ExternalMsg
    = PostRepo LeftPanel


type Msg
    = ForSelf InternalMsg
    | ForParent ExternalMsg


type alias TranslationDictionary msg =
    { onInternalMessage : InternalMsg -> msg
    , onPostRepo : LeftPanel -> msg
    }


type alias Translator parentMsg =
    Msg -> parentMsg


translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onInternalMessage, onPostRepo } msg =
    case msg of
        ForSelf internal ->
            onInternalMessage internal

        ForParent (PostRepo model) ->
            onPostRepo model
