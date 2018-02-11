port module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList, disabled)
import Html.Events exposing (onClick, on, keyCode)
import Set exposing (..)
import Char


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


type LetterDisposition
    = Available
    | Good
    | Bad


getLetterDisposition : Model -> Char -> LetterDisposition
getLetterDisposition { goodGuesses, badGuesses } letter =
    if (Set.member letter goodGuesses) then
        Good
    else if (Set.member letter badGuesses) then
        Bad
    else
        Available



-- UPDATE


type Msg
    = ChooseLetter Char
    | BodyKeyPress Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChooseLetter letter ->
            let
                good =
                    List.member letter (String.toList model.word)

                newModel =
                    { model
                        | goodGuesses =
                            if good then
                                Set.insert letter model.goodGuesses
                            else
                                model.goodGuesses
                        , badGuesses =
                            if not good then
                                Set.insert letter model.badGuesses
                            else
                                model.badGuesses
                    }
            in
                ( newModel, Cmd.none )

        BodyKeyPress code ->
            let
                msg =
                    (Char.fromCode >> Char.toUpper >> ChooseLetter) code
            in
                update msg model



-- VIEW


view : Model -> Html Msg
view model =
    div [] <|
        viewVersion model
            :: viewWord model
            :: viewLetters model


viewVersion : Model -> Html Msg
viewVersion { version } =
    div [ class "version" ] [ text version ]


viewWord : Model -> Html Msg
viewWord { word, goodGuesses } =
    div [] [ text <| maskWord word goodGuesses ]


viewLetters : Model -> List (Html Msg)
viewLetters model =
    List.map (viewLetter model) (String.toList alphabet)


viewLetter : Model -> Char -> Html Msg
viewLetter model letter =
    let
        letterDisposition =
            getLetterDisposition model letter

        classes =
            classList
                [ ( "letter"
                  , True
                  )
                , ( "letter-good"
                  , letterDisposition == Good
                  )
                , ( "letter-bad"
                  , letterDisposition == Bad
                  )
                ]
    in
        button
            [ onClick <| ChooseLetter letter
            , disabled <| letterDisposition /= Available
            , classes
            ]
            [ text <| String.fromChar letter ]


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



---- SUBSCRIPTION ----


subscriptions : Model -> Sub Msg
subscriptions model =
    bodyKeyPress BodyKeyPress


port bodyKeyPress : (Int -> msg) -> Sub msg



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
