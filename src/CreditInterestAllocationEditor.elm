module CreditInterestAllocationEditor exposing (main)

import Browser
import Data.Flags exposing (Flags)
import Data.Model exposing (Model)
import Data.Msg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Update.FeePlan as FeePlan
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
    let
        fee_plans =
            flags.fee_plans |> List.sortBy .installments_count
    in
    ( { fee_plans = fee_plans
      , original_fee_plans = fee_plans
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetCustomerFeeVariable installments_count value ->
            ( { model
                | fee_plans = FeePlan.update model installments_count value
              }
            , Cmd.none
            )


view : Model -> Html Msg
view ({ fee_plans, original_fee_plans } as model) =
    List.map2 Tuple.pair original_fee_plans fee_plans
        |> List.map FeePlan.show
        |> div []
