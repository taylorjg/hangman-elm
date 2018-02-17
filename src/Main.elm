port module Main exposing (..)

import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (class, classList, disabled, id)
import Html.Events exposing (on, onClick, keyCode)
import Set exposing (Set)
import Array exposing (Array)
import String
import Char
import Dom
import Random
import Task
import Svg exposing (Svg, svg, line, circle, path)
import Svg.Attributes exposing (viewBox, x1, y1, x2, y2, cx, cy, r, d)


-- MODEL


alphabet : List Char
alphabet =
    List.range (Char.toCode 'A') (Char.toCode 'Z')
        |> List.map Char.fromCode


words : Array String
words =
    [ "elm"
    , "react"
    , "redux"
    , "angular"
    , "ember"
    , "jasmine"
    , "mocha"
    , "enzyme"
    , "javascript"
    , "ecmascript"
    , "haskell"
    , "pascal"
    , "scala"
    , "clojure"
    , "scheme"
    , "typescript"
    , "fortran"
    ]
        |> Array.fromList
        |> Array.map String.toUpper


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
    Model flags.version InProgress Nothing maxLives "ELM" Set.empty Set.empty ! [ chooseWordCmd ]


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
    = ChooseWord
    | ChooseWordResult String
    | ChooseLetter Char
    | BodyKeyPress Int
    | FocusResult (Result Dom.Error ())


chooseWordCmd : Cmd Msg
chooseWordCmd =
    let
        wordGenerator =
            Random.map indexToWord indexGenerator

        indexToWord =
            (\index -> Maybe.withDefault "ELM" <| Array.get index words)

        indexGenerator =
            Random.int 0 <| (Array.length words) - 1
    in
        Random.generate ChooseWordResult wordGenerator


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChooseWord ->
            ( model, chooseWordCmd )

        ChooseWordResult word ->
            Model model.version InProgress Nothing maxLives word Set.empty Set.empty ! [ Cmd.none ]

        ChooseLetter letter ->
            if
                model.gameState
                    /= InProgress
                    || Set.member letter model.goodGuesses
                    || Set.member letter model.badGuesses
            then
                model ! []
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

                    cmd =
                        if newGameState == GameOver then
                            Task.attempt FocusResult (Dom.focus "btnNewGame")
                        else
                            Cmd.none
                in
                    ( newModel, cmd )

        BodyKeyPress code ->
            let
                msg =
                    (Char.fromCode >> Char.toUpper >> ChooseLetter) code
            in
                update msg model

        FocusResult _ ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "app" ] <|
        List.map (\v -> v model)
            [ viewVersion
            , viewRemainingLives
            , viewGallows
            , viewWord
            , viewLetters
            , viewControlPanel
            ]


viewRemainingLives : Model -> Html Msg
viewRemainingLives { remainingLives } =
    p [ class "remainingLives" ] [ text <| "Remaining lives: " ++ (toString remainingLives) ]


svgChildrenAlive : List (Svg Msg)
svgChildrenAlive =
    [ line [ x1 "50", y1 "280", x2 "250", y2 "280" ] []
    , line [ x1 "200", y1 "280", x2 "200", y2 "50" ] []
    , line [ x1 "200", y1 "50", x2 "100", y2 "50" ] []
    , line [ x1 "160", y1 "50", x2 "200", y2 "90" ] []
    , line [ x1 "100", y1 "50", x2 "100", y2 "80" ] []
    , circle [ cx "100", cy "95", r "15" ] []
    , line [ x1 "100", y1 "110", x2 "100", y2 "175" ] []
    , line [ x1 "100", y1 "130", x2 "70", y2 "140" ] []
    , line [ x1 "100", y1 "130", x2 "130", y2 "140" ] []
    , line [ x1 "100", y1 "175", x2 "65", y2 "215" ] []
    , line [ x1 "100", y1 "175", x2 "135", y2 "215" ] []
    ]


svgChildrenDead : List (Svg Msg)
svgChildrenDead =
    [ line [ x1 "50", y1 "280", x2 "250", y2 "280" ] []
    , line [ x1 "200", y1 "280", x2 "200", y2 "50" ] []
    , line [ x1 "200", y1 "50", x2 "100", y2 "50" ] []
    , line [ x1 "160", y1 "50", x2 "200", y2 "90" ] []
    , line [ x1 "100", y1 "50", x2 "100", y2 "80" ] []
    , circle [ cx "100", cy "95", r "15" ] []
    , line [ x1 "100", y1 "110", x2 "95", y2 "175" ] []
    , path [ d "M 98 130 A 80 80 1 0 0 90 168" ] []
    , path [ d "M 99 130 A 80 80 0 0 1 107 170" ] []
    , path [ d "M 95 175 A 80 72 1 0 0 90 228" ] []
    , path [ d "M 95 175 A 40 60 0 0 1 92 238" ] []
    ]


viewGallows : Model -> Html Msg
viewGallows { badGuesses, gameState } =
    let
        svgChildren =
            if gameState == GameOver then
                svgChildrenDead
            else
                svgChildrenAlive
    in
        svg [ id "gallows", viewBox "0 0 300 300" ] <| List.take (Set.size badGuesses) svgChildren


viewVersion : Model -> Html Msg
viewVersion { version } =
    div [ class "version" ] [ text <| "version: " ++ version ]


viewWord : Model -> Html Msg
viewWord { word, goodGuesses } =
    div [ class "word" ] [ text <| maskWord word goodGuesses ]


viewLetters : Model -> Html Msg
viewLetters model =
    let
        alphabetArray =
            Array.fromList alphabet

        rows =
            [ Array.toList <| Array.slice 0 9 alphabetArray
            , Array.toList <| Array.slice 9 18 alphabetArray
            , Array.toList <| Array.slice 18 26 alphabetArray
            ]
    in
        div [] <| List.map (viewLettersRow model) rows


viewLettersRow : Model -> List Char -> Html Msg
viewLettersRow model letters =
    div [ class "lettersRow" ] <|
        List.map (viewLetter model) letters


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


viewControlPanel : Model -> Html Msg
viewControlPanel { gameState, outcome } =
    if gameState == GameOver then
        let
            outcomeText =
                case outcome of
                    Just Won ->
                        "You won!"

                    Just Lost ->
                        "You lost!"

                    Nothing ->
                        "?"
        in
            div []
                [ p [] [ text outcomeText ]
                , button [ onClick ChooseWord, id "btnNewGame" ] [ text "New Game" ]
                ]
    else
        div [] []


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
