module Data.Flags exposing (Flags)

import Data.FeePlan exposing (FeePlan)
import Request.Alma exposing (AlmaSettings)


type alias Flags =
    { fee_plans : List FeePlan
    , alma_settings : AlmaSettings
    }
