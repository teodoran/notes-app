module Main exposing (..)

import Browser exposing (Document)
import Html exposing (Html, h1, text)
import Html.Events exposing (onClick)
import Note exposing (NoteData)
import Noteboard exposing (Noteboard)
import NotesApi


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = NewNote
    | NotesUpdate (NotesApi.Result (List NoteData))
    | NoteSaved (NotesApi.Result NoteData)
    | NoteDeleted NoteData (NotesApi.Result ())
    | NoteboardMsg Noteboard.Msg


type alias Model =
    Noteboard


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


init : () -> ( Model, Cmd Msg )
init _ =
    ( Noteboard.create, NotesApi.getAll NotesUpdate )


map : ( Noteboard, Cmd Noteboard.Msg ) -> ( Noteboard, Cmd Msg )
map ( board, cmd ) =
    ( board, Cmd.map NoteboardMsg cmd )


listenForApiCmd : Noteboard.Msg -> Cmd Msg
listenForApiCmd msg =
    case msg of
        Noteboard.SaveNote note ->
            NotesApi.save NoteSaved note

        Noteboard.DeleteNote note ->
            NotesApi.delete (NoteDeleted note) note.id

        _ ->
            Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewNote ->
            map <| Noteboard.new "" model

        NoteboardMsg noteboardMsg ->
            let
                ( board, cmd ) =
                    Noteboard.update noteboardMsg model

                apiCmd =
                    listenForApiCmd noteboardMsg
            in
            ( board, Cmd.batch [ apiCmd, Cmd.map NoteboardMsg cmd ] )

        NotesUpdate result ->
            case result of
                NotesApi.Ok notes ->
                    ( Noteboard.fromNotes notes, Cmd.none )

                NotesApi.Unrecoverable _ ->
                    ( model, Cmd.none )

        NoteSaved result ->
            map <| Noteboard.update (ignoreError Noteboard.SaveNote result) model

        NoteDeleted note _ ->
            map <| Noteboard.update (Noteboard.DeleteNote note) model


ignoreError : (result -> Noteboard.Msg) -> NotesApi.Result result -> Noteboard.Msg
ignoreError msg result =
    case result of
        NotesApi.Ok data ->
            msg data

        NotesApi.Unrecoverable _ ->
            Noteboard.NothingToSeeHere


view : Model -> Document Msg
view noteboard =
    Document "Noteboard"
        [ h1 [ onClick NewNote ] [ text "My noteboard (+)" ]
        , Noteboard.view noteboard |> Html.map NoteboardMsg
        ]
