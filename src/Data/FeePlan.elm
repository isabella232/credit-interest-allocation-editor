module Data.FeePlan exposing (FeePlan, FeePlanID, decode, empty)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type alias FeePlanID =
    Int


type alias FeePlan =
    { installments_count : Int
    , merchant_fee_variable : Int
    , merchant_fee_fixed : Int
    , customer_fee_variable : Int
    , customer_fee_fixed : Int
    , is_capped : Bool
    }


empty : FeePlan
empty =
    FeePlan 2 0 0 0 0 False


decode : Decoder FeePlan
decode =
    Decode.succeed FeePlan
        |> required "installments_count" Decode.int
        |> required "merchant_fee_variable" Decode.int
        |> required "merchant_fee_fixed" Decode.int
        |> required "customer_fee_variable" Decode.int
        |> required "customer_fee_fixed" Decode.int
        |> optional "is_capped" Decode.bool False
