module NotesApi exposing (Result(..), delete, getAll, save)

import Http
import Json.Decode
import Note exposing (NoteData, NoteID)
import Result as R


baseUrl =
    "/api/notes/"


type Result a
    = Ok a
    | Unrecoverable String


type alias StatusHandler a =
    Int -> Maybe (Result a)


mapResponse : StatusHandler a -> R.Result Http.Error a -> Result a
mapResponse statusHandler result =
    case result of
        R.Ok value ->
            Ok value

        Err error ->
            errorHandler statusHandler error


errorHandler : StatusHandler a -> Http.Error -> Result a
errorHandler statusHandler error =
    case error of
        Http.BadUrl string ->
            Unrecoverable <| "We're having some issues connecting to our server - invalid url: " ++ string

        Http.Timeout ->
            Unrecoverable "Check your internet connection"

        Http.NetworkError ->
            Unrecoverable "Check your internet connection"

        Http.BadStatus status ->
            case statusHandler status of
                Just result ->
                    result

                Nothing ->
                    case status of
                        400 ->
                            Unrecoverable "Our server gave an incompatible response"

                        _ ->
                            Unrecoverable "We're having some trouble with our server"

        Http.BadBody _ ->
            Unrecoverable "Our server gave an incompatible response"


emptyHandler : StatusHandler a
emptyHandler _ =
    Nothing


notFoundIsUnrecoverable : StatusHandler a
notFoundIsUnrecoverable status =
    case status of
        404 ->
            Just <| Unrecoverable "Our server gave an incompatible response"

        _ ->
            Nothing


getAll : (Result (List NoteData) -> msg) -> Cmd msg
getAll msg =
    Http.get
        { url = baseUrl
        , expect = Http.expectJson (mapResponse notFoundIsUnrecoverable >> msg) (Json.Decode.list Note.decoder)
        }


save : (Result NoteData -> msg) -> NoteData -> Cmd msg
save msg note =
    case note.id of
        Note.NoteID id ->
            put msg id note

        Note.NewNote ->
            post msg note


delete : (Result () -> msg) -> NoteID -> Cmd msg
delete msg id =
    case id of
        Note.NoteID idStr ->
            Http.request
                { method = "DELETE"
                , headers = []
                , url = baseUrl ++ "/" ++ idStr
                , body = Http.emptyBody
                , expect = Http.expectWhatever (mapResponse emptyHandler >> msg)
                , timeout = Nothing
                , tracker = Nothing
                }

        Note.NewNote ->
            Cmd.none


post : (Result NoteData -> msg) -> NoteData -> Cmd msg
post msg note =
    Http.post
        { url = baseUrl
        , body = Http.stringBody "text/plain" <| Note.encode note
        , expect = Http.expectJson (mapResponse notFoundIsUnrecoverable >> msg) Note.decoder
        }


put : (Result NoteData -> msg) -> String -> NoteData -> Cmd msg
put msg id note =
    Http.request
        { method = "PUT"
        , headers = []
        , url = baseUrl ++ "/" ++ id
        , body = Http.stringBody "text/plain" <| Note.encode note
        , expect = Http.expectJson (mapResponse emptyHandler >> msg) Note.decoder
        , timeout = Nothing
        , tracker = Nothing
        }
