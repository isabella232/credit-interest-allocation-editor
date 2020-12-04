module CreditInterestAllocationEditor exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    ()


type Msg
    = NoOp


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ h4 [] [ text "Pour le paiement en 2 fois" ]
            , p []
                [ span [] [ text "Vos frais : ", text "3.40", text "% par transaction" ]
                , br [] []
                , span [] [ text "Frais pour votre client : ", text "aucun" ]
                ]
            ]
        , div []
            [ h4 [] [ text "Pour le paiement en 3 fois" ]
            , p []
                [ span [] [ text "Vos frais : ", text "3.80", text "% par transaction" ]
                , br [] []
                , span [] [ text "Frais pour votre client : ", text "aucun" ]
                ]
            ]
        ]
