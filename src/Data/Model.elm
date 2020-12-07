module Data.Model exposing (Model)

import Data.FeePlan exposing (FeePlan)


type alias Model =
    { fee_plans : List FeePlan }
