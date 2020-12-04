module CreditInterestAllocationEditor exposing (main)

import Browser
import Data.Flags exposing (Flags)
import Data.Model exposing (Model)
import Data.Msg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.FeePlan as FeePlan


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { fee_plans = flags.fee_plans }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view ({ fee_plans } as model) =
    List.map FeePlan.show fee_plans
        |> div []
