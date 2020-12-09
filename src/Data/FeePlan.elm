module Data.FeePlan exposing (FeePlan, FeePlanID, FlagsFeePlan, decode, empty, fromFlagsFeePlan)

import Data.Interest as MaximumInterestRate exposing (MaximumInterestRate)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type alias FeePlanID =
    Int


type alias FlagsFeePlan =
    { installments_count : Int
    , merchant_fee_variable : Int
    , merchant_fee_fixed : Int
    , customer_fee_variable : Int
    , customer_fee_fixed : Int
    , is_capped : Bool
    , maximum_interest_rate : MaximumInterestRate
    }


type alias FeePlan =
    { installments_count : Int
    , merchant_fee_variable : Int
    , merchant_fee_fixed : Int
    , customer_fee_variable : Int
    , customer_fee_fixed : Int
    , is_capped : Bool
    , maximum_interest_rate : MaximumInterestRate
    , maybe_customer_fee_variable : Maybe Float
    }


empty : FeePlan
empty =
    FeePlan 2 0 0 0 0 False MaximumInterestRate.empty Nothing


fromFlagsFeePlan : FlagsFeePlan -> FeePlan
fromFlagsFeePlan flags_fee_plan =
    FeePlan
        flags_fee_plan.installments_count
        flags_fee_plan.merchant_fee_variable
        flags_fee_plan.merchant_fee_fixed
        flags_fee_plan.customer_fee_variable
        flags_fee_plan.customer_fee_fixed
        flags_fee_plan.is_capped
        flags_fee_plan.maximum_interest_rate
        (Just <| toFloat flags_fee_plan.customer_fee_variable / 100)


decode : Decoder FeePlan
decode =
    Decode.succeed FeePlan
        |> required "installments_count" Decode.int
        |> required "merchant_fee_variable" Decode.int
        |> required "merchant_fee_fixed" Decode.int
        |> required "customer_fee_variable" Decode.int
        |> required "customer_fee_fixed" Decode.int
        |> required "is_capped" Decode.bool
        |> required "maximum_interest" MaximumInterestRate.decode
        |> required "customer_fee_variable" decodeMaybeCustomerFeeVariable


decodeMaybeCustomerFeeVariable : Decoder (Maybe Float)
decodeMaybeCustomerFeeVariable =
    Decode.int
        |> Decode.andThen
            (\customer_fee_variable ->
                (toFloat customer_fee_variable / 100)
                    |> Just
                    |> Decode.succeed
            )
