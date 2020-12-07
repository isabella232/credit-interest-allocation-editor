module Data.Msg exposing (Msg(..))

import Data.FeePlan exposing (FeePlanID)


type Msg
    = SetCustomerFeeVariable FeePlanID String
