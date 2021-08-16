module Data.Model exposing (Model)

import Data.FeePlan exposing (FeePlan)
import Data.L10n exposing (L10n)
import Request.Alma exposing (AlmaSettings)


type alias Model =
    { fee_plans : List FeePlan
    , original_fee_plans : List FeePlan
    , alma_settings : AlmaSettings
    , is_sending : Bool
    , l10n : L10n
    , has_maximum_interest_rate_regulations : Bool
    }
