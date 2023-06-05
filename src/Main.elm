module Main exposing (Person, decodePerson, encodePerson, main)

import Browser
import Html exposing (Html, button, div, h3, pre, text, textarea)
import Html.Attributes exposing (cols, placeholder, rows)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value, object)
import String exposing (trim)


type alias Model =
    { input : String
    , parsedJson : ParsedJson
    , output : String
    }


type ParsedJson
    = NotParsed
    | Parsed Person


type alias Person =
    { name : String
    , age : Int
    , hobbies : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        rawData =
            """
            {
                "name": "John Doe",
                "age": 30,
                "hobbies": ["reading", "playing guitar"]
            }
            """
    in
    ( { input = rawData, parsedJson = NotParsed, output = "" }, Cmd.none )


type Msg
    = UpdateInput String
    | ParseJson


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput value ->
            ( { model | input = value }, Cmd.none )

        ParseJson ->
            let
                json =
                    trim model.input

                result =
                    case Decode.decodeString decodePerson json of
                        Ok value ->
                            ( { model | parsedJson = Parsed value, output = encodePerson value |> Encode.encode 0 }, Cmd.none )

                        Err _ ->
                            ( { model | parsedJson = NotParsed, output = "" }, Cmd.none )
            in
            result


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ textarea [ placeholder "Enter JSON here", rows 10, cols 80, onInput UpdateInput ] [ text model.input ]
            ]
        , div []
            [ button [ onClick ParseJson ] [ text "Parse JSON" ]
            ]
        , div []
            [ case model.parsedJson of
                NotParsed ->
                    text "JSON not parsed. Please enter your data and click 'Parse JSON'."

                Parsed person ->
                    div []
                        [ h3 [] [ text "Parsed JSON" ]
                        , pre [] [ text (Debug.toString person) ]
                        ]
            ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- JSON Decoding


decodePerson : Decoder Person
decodePerson =
    Decode.succeed Person
        |> required "name" Decode.string
        |> required "age" Decode.int
        |> required "hobbies" (Decode.list Decode.string)



-- Elm Encoding


encodePerson : Person -> Value
encodePerson person =
    object
        [ ( "name", Encode.string person.name )
        , ( "age", Encode.int person.age )
        , ( "hobbies", Encode.list Encode.string person.hobbies )
        ]
