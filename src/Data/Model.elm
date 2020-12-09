module Data.Model exposing (Model)

import Data.FeePlan exposing (FeePlan, FlagsFeePlan)
import Data.Flags exposing (Flags)
import Request.Alma exposing (AlmaSettings)


type alias Model =
    { fee_plans : List FeePlan
    , original_fee_plans : List FeePlan
    , maximum_purchase_amount : Int
    , alma_settings : AlmaSettings
    }
