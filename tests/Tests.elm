module Tests exposing (..)

import Test exposing (..)
import Expect
import Set
import Main


all : Test
all =
    describe "Model tests"
        [ test "Choosing a correct letter" <|
            \_ ->
                Main.init { version = "1" }
                    |> Tuple.first
                    |> Main.update (Main.ChooseLetter 'E')
                    |> Tuple.first
                    |> Expect.equal
                        { version = "1"
                        , word = "ELM"
                        , goodGuesses = Set.singleton 'E'
                        , badGuesses = Set.empty
                        }
        , test "Choosing an incorrect letter" <|
            \_ ->
                Main.init { version = "1" }
                    |> Tuple.first
                    |> Main.update (Main.ChooseLetter 'B')
                    |> Tuple.first
                    |> Expect.equal
                        { version = "1"
                        , word = "ELM"
                        , goodGuesses = Set.empty
                        , badGuesses = Set.singleton 'B'
                        }
        ]
