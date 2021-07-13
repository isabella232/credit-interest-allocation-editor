module Data.Model exposing (Model)

import Data.FeePlan exposing (FeePlan, FlagsFeePlan)
import Request.Alma exposing (AlmaSettings)


type alias Model =
    { fee_plans : List FeePlan
    , original_fee_plans : List FeePlan
    , alma_settings : AlmaSettings
    , is_sending : Bool
    }
