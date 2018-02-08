module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
-- import List exposing (..)
import Set exposing (..)


alphabet : String
alphabet =
    "ABCDEFGHIJKLMOPQRSTUVWXYZ"



-- MODEL


type alias Model =
    { word : String
    , goodGuesses : Set Char
    , badGuesses : Set Char
    }


init : ( Model, Cmd Msg )
init =
    ( { word = "ELM"
      , goodGuesses = Set.empty
      , badGuesses = Set.empty
      }
    , Cmd.none
    )


type Msg
    = ChooseLetter Char


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        model2 =
            case msg of
                ChooseLetter letter ->
                    let
                        correct =
                            List.member letter (String.toList model.word)
                    in
                        { model
                            | goodGuesses =
                                if correct then
                                    Set.insert letter model.goodGuesses
                                else
                                    model.goodGuesses
                            , badGuesses =
                                if not correct then
                                    Set.insert letter model.badGuesses
                                else
                                    model.badGuesses
                        }
    in
        ( model2, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] (word model :: letters model ++ [ badChoices model ])


letters : Model -> List (Html Msg)
letters model =
    String.toList alphabet
        |> List.map (\letter -> button [ onClick (ChooseLetter letter) ] [ text (String.fromChar letter) ])


badChoices : Model -> Html Msg
badChoices model =
    Set.toList model.badGuesses
        |> List.map (String.fromChar >> text)
        |> div []


word : Model -> Html Msg
word model =
    div [] [ text (maskWord model.word model.goodGuesses) ]


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


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
