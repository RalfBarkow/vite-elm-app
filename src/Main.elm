module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h3, pre, text, textarea)
import Html.Attributes exposing (cols, placeholder, rows)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode
import String exposing (trim)
import Wiki exposing (Page, pageDecoder, pageEncoder)


type alias Model =
    { input : String
    , parsedJson : ParsedJson
    , output : String
    }


type ParsedJson
    = NotParsed
    | Parsed Wiki.Page


init : () -> ( Model, Cmd Msg )
init _ =
    let
        rawData =
            """
{
  "title": "Create New Page Test",
  "story": [
    {
      "id": "fbd2c94f7cb40fbb",
      "type": "future",
      "text": "We could not find this page.",
      "title": "Create New Page Test",
      "create": {
        "type": "create",
        "item": {
          "title": "Create New Page Test",
          "story": []
        },
        "date": 1686265800897
      }
    }
  ],
  "journal": [
    {
      "type": "create",
      "item": {
        "title": "Create New Page Test",
        "story": []
      },
      "date": 1686265800897
    }
  ]
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
                    case Decode.decodeString Wiki.pageDecoder json of
                        Ok value ->
                            ( { model | parsedJson = Parsed value, output = Wiki.pageEncoder value |> Encode.encode 0 }, Cmd.none )

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

                Parsed page ->
                    div []
                        [ h3 [] [ text "Parsed JSON" ]
                        , pre [] [ text (Debug.toString page) ]
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
