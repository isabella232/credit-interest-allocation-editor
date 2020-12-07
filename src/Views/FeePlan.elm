module Views.FeePlan exposing (show)

import Data.FeePlan exposing (FeePlan)
import Data.Msg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Input.Float as MaskedPercentage
import Views.Utils exposing (euros, percents)


show : ( FeePlan, FeePlan ) -> Html Msg
show ( original_fee_plan, { installments_count, merchant_fee_variable, merchant_fee_fixed, customer_fee_variable, customer_fee_fixed, is_capped } as fee_plan ) =
    let
        fee_plan_id =
            String.fromInt installments_count
                |> (++) "fee-plan-"
    in
    div []
        [ h4 []
            [ text "Pour le paiement en "
            , text <| String.fromInt installments_count
            , text " fois"
            ]
        , p []
            [ span []
                [ strong [] [ text "Vos frais : " ]
                , show_merchant_fees merchant_fee_variable merchant_fee_fixed |> text
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
        , if customer_fee_fixed /= 0 then
            text ""

          else
            p []
                [ strong [] [ text "Ajouter des frais clients variables ?" ]
                , br [] []
                , input
                    [ type_ "radio"
                    , name fee_plan_id
                    , id <| fee_plan_id ++ "-non"
                    , checked <| customer_fee_variable == 0
                    , value "0"
                    , onInput <| (String.toFloat >> SetCustomerFeeVariable installments_count)
                    ]
                    []
                , text "\u{00A0}"
                , label [ for <| fee_plan_id ++ "-non" ] [ text "Non" ]
                , br [] []
                , input
                    [ type_ "radio"
                    , name fee_plan_id
                    , id <| fee_plan_id ++ "-oui"
                    , checked <| customer_fee_variable /= 0
                    , value "1"
                    , onInput <| (String.toFloat >> SetCustomerFeeVariable installments_count)
                    ]
                    []
                , text "\u{00A0}"
                , label [ for <| fee_plan_id ++ "-oui" ] [ text "Oui" ]
                , if customer_fee_variable == 0 then
                    text ""

                  else
                    showCustomerFeeVariableEditor fee_plan
                ]
        , if original_fee_plan /= fee_plan then
            div [ class "text-center" ] [ button [ class "btn btn-primary" ] [ text "Enregistrer" ] ]

          else
            div [] []
        ]


euros_fees : Int -> String
euros_fees euroCents =
    euros euroCents ++ " par transaction"


percent_fees : Int -> String
percent_fees percentCents =
    percents percentCents ++ " par transaction"


show_fees : Int -> Int -> String
show_fees variable fixed =
    if fixed /= 0 then
        euros_fees fixed

    else if variable /= 0 then
        percent_fees variable

    else
        "aucun"


show_merchant_fees : Int -> Int -> String
show_merchant_fees variable fixed =
    case ( fixed, variable ) of
        ( 0, 0 ) ->
            "aucun"

        ( _, 0 ) ->
            euros_fees fixed

        ( 0, _ ) ->
            percent_fees variable

        ( _, _ ) ->
            percent_fees variable ++ " + " ++ euros_fees fixed


showCustomerFeeVariableEditor : FeePlan -> Html Msg
showCustomerFeeVariableEditor { installments_count, merchant_fee_variable, customer_fee_variable } =
    let
        fee_plan_editor_id =
            String.fromInt installments_count
                |> (++) "fee-plan-"

        initialOptions =
            MaskedPercentage.defaultOptions (SetCustomerFeeVariable installments_count)

        inputOptions =
            { initialOptions
                | maxValue = Just <| toFloat (customer_fee_variable + merchant_fee_variable) / 100
                , minValue = Just 0.01
                , stepValue = Just 0.01
            }
    in
    div
        [ class "input-group"
        , style "width" "210px"
        , style "margin-left" "20px"
        , style "display" "inline-table"
        , style "vertical-align" "middle"
        ]
        [ MaskedPercentage.input
            inputOptions
            [ class "form-control", id fee_plan_editor_id ]
            (Just <| toFloat customer_fee_variable / 100)
        , label
            [ class "input-group-addon"
            , for fee_plan_editor_id
            ]
            [ text "% par transaction" ]
        ]
