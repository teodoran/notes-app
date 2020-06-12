module NoteboardSuite exposing (suite)

import Expect
import Note
import Noteboard
import Test exposing (Test, describe, test)


note : Note.NoteData
note =
    Note.NoteData Note.newID "the text of this note"


noteboard : Noteboard.Noteboard
noteboard =
    Noteboard.fromNotes [ note ]


suite : Test
suite =
    describe "The Noteboard module"
        [ describe "create"
            [ test "creates empty" <|
                \_ ->
                    Expect.equal [] (Noteboard.toList Noteboard.create)
            ]
        , describe "new"
            [ test "adds new note with text" <|
                \_ ->
                    let
                        text =
                            "some todo text"

                        ( board, _ ) =
                            Noteboard.new text Noteboard.create
                    in
                    Expect.equal (Just text) (Noteboard.get Note.newID board |> Maybe.map .text)
            ]
        , describe "fromList"
            [ test "creates Noteboard with note" <|
                \_ ->
                    Expect.equal (Just note) (Noteboard.get note.id noteboard)
            , test "has same size" <|
                \_ ->
                    Expect.equal 1 (Noteboard.toList noteboard |> List.length)
            ]
        , describe "update"
            [ test "does nothing for NothingToSeeHere" <|
                \_ ->
                    Expect.equal noteboard (update Noteboard.NothingToSeeHere noteboard)
            , test "removes note for DeleteNote" <|
                \_ ->
                    let
                        actual =
                            update (Noteboard.DeleteNote note) noteboard
                                |> Noteboard.toList
                    in
                    Expect.equalLists [] actual
            , test "updates text of note for ChangeNote" <|
                \_ ->
                    let
                        newText =
                            "updated text"

                        actual =
                            update (Noteboard.ChangeNote note newText) noteboard
                                |> Noteboard.get note.id
                                |> Maybe.map .text
                    in
                    Expect.equal (Just newText) actual
            ]
        ]


update : Noteboard.Msg -> Noteboard.Noteboard -> Noteboard.Noteboard
update msg =
    Noteboard.update msg >> Tuple.first
