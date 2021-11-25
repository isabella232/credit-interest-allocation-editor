module Data.FeePlan exposing (FeePlan, FeePlanID, FlagsFeePlan, decode, empty, feePlanToID, fromFlagsFeePlan)

import Data.Interest as MaximumInterestRate exposing (MaximumInterestRate)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import String exposing (left)


type alias FeePlanID =
    String


type alias FeePlanIDAble a =
    { a | installments_count : Int, kind : String }


feePlanToID : FeePlanIDAble a -> FeePlanID
feePlanToID { installments_count, kind } =
    let
        short_kind =
            left 1 kind

        sortable_ic =
            if installments_count < 10 then
                String.fromInt installments_count |> (++) "0"

            else
                String.fromInt installments_count
    in
    short_kind
        |> (++) "-"
        |> (++) sortable_ic
        |> (++) "fee-plan-"


type alias FlagsFeePlan =
    { kind : String
    , installments_count : Int
    , merchant_fee_variable : Int
    , merchant_fee_fixed : Int
    , customer_fee_variable : Int
    , customer_fee_fixed : Int
    , customer_lending_rate : Int
    , capped : Bool
    , maximum_interest_rate : MaximumInterestRate
    , max_purchase_amount : Int
    , is_under_maximum_interest_regulated_rate : Bool
    }


type alias FeePlan =
    { kind : String
    , installments_count : Int
    , merchant_fee_variable : Int
    , merchant_fee_fixed : Int
    , customer_fee_variable : Int
    , customer_fee_fixed : Int
    , customer_lending_rate : Int
    , capped : Bool
    , maximum_interest_rate : MaximumInterestRate
    , max_purchase_amount : Int
    , maybe_customer_fee_variable : Maybe Float
    , is_under_maximum_interest_regulated_rate : Bool
    }


empty : FeePlan
empty =
    FeePlan "general" 2 0 0 0 0 0 False MaximumInterestRate.empty 0 Nothing True


fromFlagsFeePlan : FlagsFeePlan -> FeePlan
fromFlagsFeePlan flags_fee_plan =
    FeePlan
        flags_fee_plan.kind
        flags_fee_plan.installments_count
        flags_fee_plan.merchant_fee_variable
        flags_fee_plan.merchant_fee_fixed
        flags_fee_plan.customer_fee_variable
        flags_fee_plan.customer_fee_fixed
        flags_fee_plan.customer_lending_rate
        flags_fee_plan.capped
        flags_fee_plan.maximum_interest_rate
        flags_fee_plan.max_purchase_amount
        (Just <| toFloat flags_fee_plan.customer_fee_variable / 100)
        flags_fee_plan.is_under_maximum_interest_regulated_rate


decode : Decoder FeePlan
decode =
    Decode.succeed FeePlan
        |> required "kind" Decode.string
        |> required "installments_count" Decode.int
        |> required "merchant_fee_variable" Decode.int
        |> required "merchant_fee_fixed" Decode.int
        |> required "customer_fee_variable" Decode.int
        |> required "customer_fee_fixed" Decode.int
        |> required "customer_lending_rate" Decode.int
        |> required "capped" Decode.bool
        |> required "maximum_interest_rate" MaximumInterestRate.decode
        |> required "max_purchase_amount" Decode.int
        |> required "customer_fee_variable" decodeMaybeCustomerFeeVariable
        |> required "is_under_maximum_interest_regulated_rate" Decode.bool


decodeMaybeCustomerFeeVariable : Decoder (Maybe Float)
decodeMaybeCustomerFeeVariable =
    Decode.int
        |> Decode.andThen
            (\customer_fee_variable ->
                (toFloat customer_fee_variable / 100)
                    |> Just
                    |> Decode.succeed
            )
