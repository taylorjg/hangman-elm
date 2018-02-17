module Tests exposing (..)

import Test exposing (..)
import Expect
import Set
import Main exposing (..)


all : Test
all =
    let
        flags =
            { version = "1" }

        initialState =
            Model flags.version InProgress Nothing maxLives "ELM" Set.empty Set.empty
    in
        describe "Tests for the update function"
            [ test "Choosing a correct letter" <|
                \_ ->
                    initialState
                        |> update (ChooseLetter 'E')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = InProgress
                            , outcome = Nothing
                            , remainingLives = maxLives
                            , word = "ELM"
                            , goodGuesses = Set.singleton 'E'
                            , badGuesses = Set.empty
                            }
            , test "Choosing an incorrect letter" <|
                \_ ->
                    initialState
                        |> update (ChooseLetter 'B')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = InProgress
                            , outcome = Nothing
                            , remainingLives = maxLives - 1
                            , word = "ELM"
                            , goodGuesses = Set.empty
                            , badGuesses = Set.singleton 'B'
                            }
            , test "Ignore repeated incorrect letter" <|
                \_ ->
                    { initialState
                        | badGuesses = Set.singleton 'B'
                        , remainingLives = maxLives - 1
                    }
                        |> update (ChooseLetter 'B')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = InProgress
                            , outcome = Nothing
                            , remainingLives = maxLives - 1
                            , word = "ELM"
                            , goodGuesses = Set.empty
                            , badGuesses = Set.singleton 'B'
                            }
            , test "Choosing an invalid character" <|
                \_ ->
                    initialState
                        |> update (ChooseLetter '?')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = InProgress
                            , outcome = Nothing
                            , remainingLives = maxLives
                            , word = "ELM"
                            , goodGuesses = Set.empty
                            , badGuesses = Set.empty
                            }
            , test "ignore ChooseLetter when GameOver" <|
                \_ ->
                    { initialState | gameState = GameOver }
                        |> update (ChooseLetter 'E')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = GameOver
                            , outcome = Nothing
                            , remainingLives = maxLives
                            , word = "ELM"
                            , goodGuesses = Set.empty
                            , badGuesses = Set.empty
                            }
            , test "choosing last good letter => GameOver / Won" <|
                \_ ->
                    { initialState | goodGuesses = "EL" |> String.toList >> Set.fromList }
                        |> update (ChooseLetter 'M')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = GameOver
                            , outcome = Just Won
                            , remainingLives = maxLives
                            , word = "ELM"
                            , goodGuesses = "ELM" |> String.toList >> Set.fromList
                            , badGuesses = Set.empty
                            }
            , test "choosing bad letter when only one life remains => GameOver / Lost" <|
                \_ ->
                    { initialState
                        | badGuesses = "ABCDFGHIJK" |> String.toList >> Set.fromList
                        , remainingLives = 1
                    }
                        |> update (ChooseLetter 'Z')
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = GameOver
                            , outcome = Just Lost
                            , remainingLives = 0
                            , word = "ELM"
                            , goodGuesses = Set.empty
                            , badGuesses = "ABCDFGHIJKZ" |> String.toList >> Set.fromList
                            }
            , test "ChooseWordResult starts a new game" <|
                \_ ->
                    { initialState
                        | gameState = GameOver
                        , outcome = Just Won
                        , goodGuesses = "ELM" |> String.toList >> Set.fromList
                    }
                        |> update (ChooseWordResult (Ok "REACT"))
                        |> Tuple.first
                        |> Expect.equal
                            { version = flags.version
                            , gameState = InProgress
                            , outcome = Nothing
                            , remainingLives = maxLives
                            , word = "REACT"
                            , goodGuesses = Set.empty
                            , badGuesses = Set.empty
                            }
            ]
