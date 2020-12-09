module Data.Interest exposing (MaximumInterestRate, decode, empty)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type alias MaximumInterestRate =
    { below_3000 : Int
    , over_3000 : Int
    , over_6000 : Int
    }


empty : MaximumInterestRate
empty =
    MaximumInterestRate 153 79 41


decode : Decoder MaximumInterestRate
decode =
    Decode.succeed MaximumInterestRate
        |> required "below_3000" Decode.int
        |> required "over_3000" Decode.int
        |> required "over_6000" Decode.int
