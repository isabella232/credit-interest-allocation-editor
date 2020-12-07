module Data.Flags exposing (Flags)

import Data.FeePlan exposing (FeePlan)


type alias Flags =
    { fee_plans : List FeePlan }
