module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Set exposing (..)


-- MODEL


alphabet : String
alphabet =
    "ABCDEFGHIJKLMOPQRSTUVWXYZ"


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
    ( Model flags.version "ELM" Set.empty Set.empty
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
    div [] <| version model :: word model :: letters model


version : Model -> Html Msg
version { version } =
    div [ class "version" ] [ text version ]


letters : Model -> List (Html Msg)
letters model =
    List.map (letterButton model) (String.toList alphabet)


letterButton : Model -> Char -> Html Msg
letterButton { goodGuesses, badGuesses } letter =
    let
        classes =
            classList
                [ ( "letter"
                  , True
                  )
                , ( "letter-correct"
                  , Set.member letter goodGuesses
                  )
                , ( "letter-incorrect"
                  , Set.member letter badGuesses
                  )
                ]
    in
        button [ onClick (ChooseLetter letter), classes ] [ text <| String.fromChar letter ]


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
