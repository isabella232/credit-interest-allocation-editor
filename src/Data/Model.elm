module Data.Model exposing (Model)

import Data.FeePlan exposing (FeePlan)
import Data.Flags exposing (Flags)


type alias Model =
    { fee_plans : List FeePlan
    , original_fee_plans : List FeePlan
    }
