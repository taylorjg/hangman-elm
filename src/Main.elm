port module Main exposing (..)

import Html exposing (Html, button, div, img, p, span, text)
import Html.Attributes exposing (alt, class, classList, disabled, id, src, title)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Array exposing (Array)
import String
import Char
import Dom
import Random
import Task
import Svg exposing (Svg, svg, line, circle, path)
import Svg.Attributes exposing (viewBox, x1, y1, x2, y2, cx, cy, r, d)
import Http
import Json.Decode


-- MODEL


alphabet : List Char
alphabet =
    List.range (Char.toCode 'A') (Char.toCode 'Z')
        |> List.map Char.fromCode


letterRows : List (List Char)
letterRows =
    let
        alphabetArray =
            Array.fromList alphabet
    in
        List.map (\( from, to ) -> (Array.slice from to >> Array.toList) alphabetArray)
            [ ( 0, 9 )
            , ( 9, 18 )
            , ( 18, 26 )
            ]


fallbackWords : Array String
fallbackWords =
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


lastFallbackWordIndex : Int
lastFallbackWordIndex =
    Array.length fallbackWords - 1


maxLives : Int
maxLives =
    11


type alias Flags =
    { version : String
    }


type GameState
    = ChoosingWord
    | InProgress
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
    , errorMessage : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.version ChoosingWord Nothing maxLives "" Set.empty Set.empty Nothing, chooseWordCmd )


type LetterDisposition
    = Available
    | Good
    | Bad


type ChoiceDisposition
    = Correct
    | Incorrect


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
    if List.member letter (String.toList word) then
        Correct
    else
        Incorrect



-- UPDATE


type Msg
    = ChooseWord
    | ChooseWordResult (Result Http.Error String)
    | ChooseWordFallbackResult String
    | ChooseLetter Char
    | BodyKeyPress Int
    | FocusResult (Result Dom.Error ())


chooseWordCmd : Cmd Msg
chooseWordCmd =
    let
        request =
            Http.get "/api/chooseWord" decodeWord
    in
        Http.send ChooseWordResult request


decodeWord : Json.Decode.Decoder String
decodeWord =
    Json.Decode.at [ "word" ] Json.Decode.string


chooseWordFallbackCmd : Cmd Msg
chooseWordFallbackCmd =
    let
        generator =
            Random.int 0 lastFallbackWordIndex
                |> Random.map (flip Array.get fallbackWords)
                |> Random.map (Maybe.withDefault "ELM")
    in
        Random.generate ChooseWordFallbackResult generator


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChooseWord ->
            ( Model model.version ChoosingWord Nothing maxLives "" Set.empty Set.empty Nothing, chooseWordCmd )

        ChooseWordResult (Ok word) ->
            ( { model | gameState = InProgress, word = word }, Cmd.none )

        ChooseWordResult (Err httpError) ->
            ( { model | errorMessage = Just <| toString httpError }, chooseWordFallbackCmd )

        ChooseWordFallbackResult word ->
            ( { model | gameState = InProgress, word = word }, Cmd.none )

        ChooseLetter letter ->
            if
                model.gameState
                    /= InProgress
                    || not (List.member letter alphabet)
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
    div [ class "app" ]
        [ viewVersion model
        , div [ id "panes" ]
            [ div [ id "pane1" ]
                [ viewRemainingLives model
                , viewGallows model
                ]
            , div [ id "pane2" ]
                [ viewWord model
                , viewLetters model
                , viewControlPanel model
                , viewErrorPanel model
                ]
            ]
        ]


viewVersion : Model -> Html Msg
viewVersion { version } =
    div [ class "version" ] [ text <| "version: " ++ version ]


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
viewGallows { badGuesses, outcome } =
    let
        svgChildren =
            if outcome == Just Lost then
                svgChildrenDead
            else
                svgChildrenAlive
    in
        svg [ id "gallows", viewBox "0 0 300 300" ] <| List.take (Set.size badGuesses) svgChildren


viewWord : Model -> Html Msg
viewWord { gameState, word, goodGuesses } =
    p []
        [ case gameState of
            ChoosingWord ->
                span [ class "word-loading" ]
                    [ img [ src "/spinner.gif", alt "Spinner" ] []
                    , text "(choosing a word...)"
                    ]

            InProgress ->
                div [ class "word" ] [ text <| maskWord word goodGuesses ]

            GameOver ->
                div [ class "word" ] [ text word ]
        ]


viewLetters : Model -> Html Msg
viewLetters model =
    if model.gameState == InProgress then
        div [] <| List.map (viewLettersRow model) letterRows
    else
        div [] []


viewLettersRow : Model -> List Char -> Html Msg
viewLettersRow model letterRow =
    div [ class "lettersRow" ] <|
        List.map (viewLetter model) letterRow


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


viewErrorPanel : Model -> Html Msg
viewErrorPanel { errorMessage } =
    div [ class "error-panel" ] <|
        case errorMessage of
            Just errorMessageText ->
                [ span []
                    [ img
                        [ src "/warningTriangle.png"
                        , alt "Warning triangle"
                        , title errorMessageText
                        ]
                        []
                    , text "(using a local dictionary due to a server error)"
                    ]
                ]

            Nothing ->
                []


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
