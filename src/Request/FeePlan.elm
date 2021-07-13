module Request.FeePlan exposing (..)

import Data.FeePlan as FeePlan exposing (FeePlan)
import HttpBuilder
import Json.Encode as Encode
import Request.Alma as Alma exposing (AlmaSettings, send)


updateFeePlan : FeePlan -> (Result Alma.Error FeePlan -> msg) -> AlmaSettings -> Cmd msg
updateFeePlan fee_plan toMsg settings =
    Alma.endpointUrl settings.apiServer Alma.MerchantFeePlan
        |> HttpBuilder.post
        |> HttpBuilder.withCredentials
        |> HttpBuilder.withJsonBody (encodeData settings fee_plan)
        |> HttpBuilder.withExpect (Alma.expectJson toMsg FeePlan.decode)
        |> send


encodeData : AlmaSettings -> FeePlan -> Encode.Value
encodeData alma_settings fee_plan =
    Encode.object
        [ ( "installments_count", Encode.int fee_plan.installments_count )
        , ( "customer_fee_variable", Encode.int fee_plan.customer_fee_variable )
        , ( "kind", Encode.string fee_plan.kind )
        , ( "csrf_token", Encode.string alma_settings.csrfToken )
        ]
