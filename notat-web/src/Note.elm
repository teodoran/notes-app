module Note exposing (NoteData, NoteID(..), decoder, encode, idToString, newID)

import Json.Decode as Decode


type NoteID
    = NoteID String
    | NewNote


type alias NoteData =
    { id : NoteID
    , text : String

    --, created : Time.Posix
    --, updated: Time.Posix
    }


newID : NoteID
newID =
    NewNote


idToString : NoteID -> String
idToString id =
    case id of
        NoteID str ->
            str

        NewNote ->
            "___new_note"


decoder : Decode.Decoder NoteData
decoder =
    Decode.map2 NoteData
        idDecoder
        (Decode.field "text" Decode.string)


idDecoder : Decode.Decoder NoteID
idDecoder =
    Decode.map NoteID (Decode.field "id" Decode.string)


encode : NoteData -> String
encode noteData =
    noteData.text
