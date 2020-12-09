module Data.Flags exposing (Flags)

import Data.FeePlan exposing (FlagsFeePlan)
import Request.Alma exposing (AlmaSettings)


type alias Flags =
    { fee_plans : List FlagsFeePlan
    , maximum_purchase_amount : Maybe Int
    , alma_settings : AlmaSettings
    }
