module Data.Msg exposing (Msg(..))

import Data.FeePlan exposing (FeePlan, FeePlanID)
import Request.Alma as Alma


type Msg
    = SetCustomerFeeVariable FeePlanID (Maybe Float)
    | UpdateFeePlan FeePlan
    | FeePlanUpdated FeePlan (Result Alma.Error FeePlan)
