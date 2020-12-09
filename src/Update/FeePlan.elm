module Update.FeePlan exposing (..)

import Data.FeePlan as FeePlan exposing (FeePlan, FeePlanID)
import Data.Model exposing (Model)


update : Model -> FeePlanID -> Maybe Float -> List FeePlan
update model installments_count maybe_value =
    let
        fee_plan =
            model.fee_plans
                |> List.filter (.installments_count >> (==) installments_count)
                |> List.head
                |> Maybe.withDefault FeePlan.empty

        original_fee_plan =
            model.original_fee_plans
                |> List.filter (.installments_count >> (==) installments_count)
                |> List.head
                |> Maybe.withDefault FeePlan.empty

        other_fee_plans =
            model.fee_plans
                |> List.filter (.installments_count >> (/=) installments_count)

        new_customer_fee_variable =
            case maybe_value of
                Nothing ->
                    1

                Just value ->
                    let
                        cappedValue =
                            value
                                * 100
                                |> round
                                |> min fee_plan.maximum_interest_rate.below_3000
                    in
                    if fee_plan.customer_fee_variable == 0 then
                        if original_fee_plan.customer_fee_variable /= 0 then
                            original_fee_plan.customer_fee_variable

                        else
                            100

                    else if value == -1 then
                        0

                    else if value == 0 then
                        1

                    else
                        cappedValue

        total_fee_variable =
            original_fee_plan.merchant_fee_variable + original_fee_plan.customer_fee_variable

        new_merchant_fee_variable =
            total_fee_variable - new_customer_fee_variable

        new_fee_plan =
            { fee_plan
                | customer_fee_variable = new_customer_fee_variable
                , merchant_fee_variable = new_merchant_fee_variable
            }
    in
    (new_fee_plan :: other_fee_plans)
        |> List.sortBy .installments_count
