module Noteboard exposing (Msg(..), Noteboard, create, fromNotes, get, new, toList, update, view)

import Browser.Dom as Dom
import Dict exposing (Dict)
import Html exposing (Html, blockquote, div, i, textarea)
import Html.Attributes as Attr exposing (class, id, placeholder, value)
import Html.Events exposing (onBlur, onClick, onDoubleClick, onInput)
import Note exposing (NoteData, NoteID, idToString)
import Task


type Noteboard
    = Noteboard (Dict String Note)


type Note
    = SavedNote NoteData
    | EditableNote NoteData


type Msg
    = SaveNote NoteData
    | EditNote NoteData
    | ChangeNote NoteData String
    | DeleteNote NoteData
    | NothingToSeeHere


create : Noteboard
create =
    Noteboard Dict.empty


fromNotes : List NoteData -> Noteboard
fromNotes =
    List.map (\n -> ( idToString n.id, SavedNote n )) >> Dict.fromList >> Noteboard


noteData : Note -> NoteData
noteData note =
    case note of
        SavedNote data ->
            data

        EditableNote data ->
            data


get : NoteID -> Noteboard -> Maybe NoteData
get id (Noteboard board) =
    Dict.get (idToString id) board
        |> Maybe.map noteData


set : NoteID -> Note -> Noteboard -> Noteboard
set id note (Noteboard board) =
    Noteboard <| Dict.insert (idToString id) note board


remove : NoteID -> Noteboard -> Noteboard
remove id (Noteboard board) =
    Noteboard <| Dict.remove (idToString id) board


new : String -> Noteboard -> ( Noteboard, Cmd Msg )
new text board =
    let
        note =
            NoteData Note.newID text
    in
    ( set note.id (EditableNote note) board, focusNote note.id )


focusNote : NoteID -> Cmd Msg
focusNote =
    noteInputId >> Dom.focus >> Task.attempt (\_ -> NothingToSeeHere)


update : Msg -> Noteboard -> ( Noteboard, Cmd Msg )
update msg board =
    case msg of
        SaveNote note ->
            let
                updatedBoard =
                    set note.id (SavedNote note) board
                        |> remove Note.newID
            in
            ( updatedBoard, Cmd.none )

        EditNote note ->
            ( set note.id (EditableNote note) board, focusNote note.id )

        ChangeNote note text ->
            ( set note.id (EditableNote { note | text = text }) board, Cmd.none )

        DeleteNote note ->
            ( remove note.id board, Cmd.none )

        NothingToSeeHere ->
            ( board, Cmd.none )


toList : Noteboard -> List Note
toList (Noteboard board) =
    Dict.values board


view : Noteboard -> Html Msg
view board =
    toList board
        |> List.map viewNote
        |> div [ id "notater" ]


noteInputId : NoteID -> String
noteInputId =
    idToString >> (++) "note-input-"


viewNote : Note -> Html Msg
viewNote note =
    case note of
        SavedNote saved ->
            viewSavedNote saved

        EditableNote edit ->
            viewEditNote edit


viewSavedNote : NoteData -> Html Msg
viewSavedNote note =
    viewNoteContainer note
        [ i [ class "icon-close top-right-corner grey", onClick <| DeleteNote note ] []
        , blockquote [ onDoubleClick <| EditNote note ] [ Html.text note.text ]
        ]


viewEditNote : NoteData -> Html Msg
viewEditNote note =
    viewNoteContainer note
        [ textarea
            [ onBlur <| SaveNote note
            , onInput <| ChangeNote note
            , Attr.id <| noteInputId note.id
            , value note.text
            , placeholder "Todo..."
            ]
            []
        ]


viewNoteContainer : NoteData -> List (Html Msg) -> Html Msg
viewNoteContainer note content =
    div [ Attr.id <| "note-" ++ idToString note.id, class "notat" ]
        [ i [ class "pin" ] []
        , div [ class "text" ] content
        ]
