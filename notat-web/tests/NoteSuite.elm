module NoteSuite exposing (suite)

import Expect exposing (Expectation)
import Json.Decode
import Json.Encode
import Note
import Test exposing (..)


note =
    Note.NoteData (Note.NoteID "some id") "some todo text"


suite : Test
suite =
    describe "The Note module"
        [ describe "idToString"
            [ test "___new_note for NewID" <|
                \_ -> Expect.equal "___new_note" (Note.idToString Note.newID)
            , test "the id of a NoteID" <|
                \_ -> Expect.equal "the_id" (Note.idToString <| Note.NoteID "the_id")
            ]
        , describe "decoder"
            [ test "decodes note json" <|
                \_ ->
                    let
                        noteVal =
                            Json.Encode.object
                                [ ( "id", Json.Encode.string <| Note.idToString note.id )
                                , ( "text", Json.Encode.string note.text )
                                ]
                    in
                    Expect.equal (Just note) (resultAsMaybe <| Json.Decode.decodeValue Note.decoder noteVal)
            ]
        , describe "encode"
            [ test "encodes text as string" <|
                \_ ->
                    Expect.equal note.text (Note.encode note)
            ]
        ]


resultAsMaybe : Result Json.Decode.Error a -> Maybe a
resultAsMaybe result =
    case result of
        Ok value ->
            Just value

        Err _ ->
            Nothing
