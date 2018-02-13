port module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, classList, disabled)
import Html.Events exposing (onClick, on, keyCode)
import Set exposing (Set)
import String
import Char


-- MODEL


alphabet : List Char
alphabet =
    String.toList "ABCDEFGHIJKLMOPQRSTUVWXYZ"


maxLives : Int
maxLives =
    11


type alias Flags =
    { version : String
    }


type GameState
    = InProgress
    | GameOver


type Outcome
    = Won
    | Lost


type alias Model =
    { version : String
    , gameState : GameState
    , outcome : Maybe Outcome
    , remainingLives : Int
    , word : String
    , goodGuesses : Set Char
    , badGuesses : Set Char
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.version InProgress Nothing maxLives "ELM" Set.empty Set.empty
    , Cmd.none
    )


type LetterDisposition
    = Available
    | Good
    | Bad


type ChoiceDisposition
    = Correct
    | Incorrect
    | Invalid


getLetterDisposition : Model -> Char -> LetterDisposition
getLetterDisposition { goodGuesses, badGuesses } letter =
    if (Set.member letter goodGuesses) then
        Good
    else if (Set.member letter badGuesses) then
        Bad
    else
        Available


getChoiceDisposition : Model -> Char -> ChoiceDisposition
getChoiceDisposition { word } letter =
    case ( List.member letter alphabet, List.member letter (String.toList word) ) of
        ( True, True ) ->
            Correct

        ( True, False ) ->
            Incorrect

        ( False, _ ) ->
            Invalid



-- UPDATE


type Msg
    = ChooseLetter Char
    | BodyKeyPress Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChooseLetter letter ->
            if model.gameState /= InProgress then
                ( model, Cmd.none )
            else
                let
                    choiceDisposition =
                        getChoiceDisposition model letter

                    newGoodGuesses =
                        if choiceDisposition == Correct then
                            Set.insert letter model.goodGuesses
                        else
                            model.goodGuesses

                    ( newBadGuesses, newRemainingLives ) =
                        if choiceDisposition == Incorrect then
                            ( Set.insert letter model.badGuesses, model.remainingLives - 1 )
                        else
                            ( model.badGuesses, model.remainingLives )

                    ( newGameState, newOutcome ) =
                        if (String.toList >> Set.fromList >> Set.size) model.word == Set.size newGoodGuesses then
                            ( GameOver, Just Won )
                        else if (newRemainingLives == 0) then
                            ( GameOver, Just Lost )
                        else
                            ( model.gameState, model.outcome )

                    newModel =
                        { model
                            | gameState = newGameState
                            , outcome = newOutcome
                            , goodGuesses = newGoodGuesses
                            , badGuesses = newBadGuesses
                            , remainingLives = newRemainingLives
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
    List.map (viewLetter model) alphabet


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
