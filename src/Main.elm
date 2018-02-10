module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Set exposing (..)


alphabet : String
alphabet =
    "ABCDEFGHIJKLMOPQRSTUVWXYZ"



-- MODEL


type alias Flags =
    { version : String
    }


type alias Model =
    { version : String
    , word : String
    , goodGuesses : Set Char
    , badGuesses : Set Char
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { version = flags.version
      , word = "ELM"
      , goodGuesses = Set.empty
      , badGuesses = Set.empty
      }
    , Cmd.none
    )


type Msg
    = ChooseLetter Char


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChooseLetter letter ->
            let
                goodLetter =
                    List.member letter (String.toList model.word)

                newModel =
                    { model
                        | goodGuesses =
                            if goodLetter then
                                Set.insert letter model.goodGuesses
                            else
                                model.goodGuesses
                        , badGuesses =
                            if not goodLetter then
                                Set.insert letter model.badGuesses
                            else
                                model.badGuesses
                    }
            in
                ( newModel, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] (version model :: word model :: letters ++ [ badChoices model ])


version : Model -> Html Msg
version { version } =
    div [ class "version" ] [ text version ]


letters : List (Html Msg)
letters =
    String.toList alphabet
        |> List.map (\letter -> button [ onClick (ChooseLetter letter) ] [ text <| String.fromChar letter ])


badChoices : Model -> Html Msg
badChoices { badGuesses } =
    Set.toList badGuesses
        |> List.map (String.fromChar >> text)
        |> div []


word : Model -> Html Msg
word { word, goodGuesses } =
    div [] [ text <| maskWord word goodGuesses ]


maskWord : String -> Set Char -> String
maskWord word goodGuesses =
    String.map
        (\letter ->
            if Set.member letter goodGuesses then
                letter
            else
                '-'
        )
        word



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
