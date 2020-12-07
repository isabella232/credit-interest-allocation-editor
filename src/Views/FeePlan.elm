module Views.FeePlan exposing (show)

import Data.FeePlan exposing (FeePlan)
import Data.Msg exposing (Msg(..))
import Html exposing (..)
import Views.Utils exposing (euros, percents)


show : FeePlan -> Html Msg
show ({ installments_count, merchant_fee_variable, merchant_fee_fixed, customer_fee_variable, customer_fee_fixed, is_capped } as fee_plan) =
    div []
        [ h4 []
            [ text "Pour le paiement en "
            , text <| String.fromInt installments_count
            , text " fois"
            ]
        , p []
            [ span []
                [ strong [] [ text "Vos frais : " ]
                , show_fees merchant_fee_variable merchant_fee_fixed |> text
                ]
            , br [] []
            , span []
                [ strong [] [ text "Frais client : " ]
                , show_fees customer_fee_variable customer_fee_fixed |> text
                , if is_capped then
                    text " déduits des frais marchands"

                  else
                    text ""
                ]
            ]
        ]


show_fees : Int -> Int -> String
show_fees variable fixed =
    if fixed /= 0 then
        euros fixed ++ " par transaction"

    else if variable /= 0 then
        percents variable ++ " par transaction"

    else
        "aucun"
