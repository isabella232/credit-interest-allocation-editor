module CreditInterestAllocationEditor exposing (main)

import Browser
import Data.FeePlan as FeePlan
import Data.Flags exposing (Flags)
import Data.Model exposing (Model)
import Data.Msg exposing (Msg(..))
import Html exposing (..)
import Request.FeePlan as FeePlan
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
            flags.fee_plans
                |> List.sortBy .installments_count
                |> List.map FeePlan.fromFlagsFeePlan
    in
    ( { fee_plans = fee_plans
      , original_fee_plans = fee_plans
      , alma_settings = flags.alma_settings
      , is_sending = False
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

        UpdateFeePlan fee_plan ->
            ( { model | is_sending = True }
            , FeePlan.updateFeePlan fee_plan (FeePlanUpdated fee_plan) model.alma_settings
            )

        FeePlanUpdated _ (Err err) ->
            -- let
            --     _ =
            --         Alma.errorToString err
            --             |> Debug.log "An error occured while loading email templates"
            -- in
            -- Keep demo templates
            ( { model | is_sending = False }, Cmd.none )

        FeePlanUpdated original_fee_plan (Ok new_fee_plan) ->
            let
                new_original_fee_plans =
                    model.original_fee_plans
                        |> List.filter (\i -> i.installments_count /= original_fee_plan.installments_count)
                        |> (::) new_fee_plan
                        |> List.sortBy .installments_count

                new_fee_plans =
                    model.fee_plans
                        |> List.filter (\i -> i.installments_count /= original_fee_plan.installments_count)
                        |> (::) new_fee_plan
                        |> List.sortBy .installments_count
            in
            ( { model
                | is_sending = False
                , fee_plans = new_fee_plans
                , original_fee_plans = new_original_fee_plans
              }
            , Cmd.none
            )


view : Model -> Html Msg
view { fee_plans, original_fee_plans, is_sending } =
    List.map2 Tuple.pair original_fee_plans fee_plans
        |> List.map (FeePlan.show is_sending)
        |> div []
