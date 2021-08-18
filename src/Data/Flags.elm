module Data.Flags exposing (Flags)

import Data.FeePlan exposing (FlagsFeePlan)
import Json.Decode as Decode
import Request.Alma exposing (AlmaSettings)


type alias Flags =
    { fee_plans : List FlagsFeePlan
    , alma_settings : AlmaSettings
    , l10n : Decode.Value
    }
