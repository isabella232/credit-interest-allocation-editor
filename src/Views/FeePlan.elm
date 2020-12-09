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
            div [ class "row" ]
                [ div [ class "col-sm-6" ]
                    [ strong [] [ text "Ajouter des frais clients variables ?" ]
                    , br [] []
                    , input
                        [ type_ "radio"
                        , name fee_plan_id
                        , id <| fee_plan_id ++ "-non"
                        , checked <| customer_fee_variable == 0
                        , value "-1"
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
                    , if original_fee_plan /= fee_plan then
                        div [ class "text-center", style "margin" "20px" ]
                            [ button [ class "btn btn-primary" ] [ text "Enregistrer" ]
                            ]

                      else
                        div [] []
                    ]
                , if customer_fee_variable == 0 then
                    text ""

                  else
                    showInterestPanel fee_plan
                ]
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


showInterestPanel : FeePlan -> Html Msg
showInterestPanel { customer_fee_variable, merchant_fee_variable, maximum_interest_rate } =
    let
        customerFeeShare =
            (toFloat customer_fee_variable / toFloat maximum_interest_rate.below_3000 * 0.5 * 10000)
                |> round
                |> Basics.min 10000
                |> percents
                |> String.replace "\u{00A0}" ""
                |> String.replace "," "."

        exampleAmount =
            30000

        effectiveClientFee =
            Basics.min customer_fee_variable maximum_interest_rate.below_3000

        effectiveMerchantFee =
            customer_fee_variable + merchant_fee_variable - effectiveClientFee

        exampleClientFee =
            round <| toFloat effectiveClientFee * exampleAmount / 10000

        exampleMerchantFee =
            round <| toFloat effectiveMerchantFee * exampleAmount / 10000
    in
    div
        [ class "col-sm-6"
        , style "background-color" "#f0f8ff"
        , style "padding-top" "20px"
        ]
        [ div [ class "row" ]
            [ div
                [ class "col-xs-6"
                , style "color" "#4c86e5"
                , style "font-weight" "bold"
                , style "font-size" "0.9em"
                ]
                [ text "Frais client" ]
            , div
                [ class "col-xs-6 text-right"
                , style "color" "#273d52"
                , style "font-weight" "bold"
                , style "font-size" "0.9em"
                ]
                [ text "Frais marchands" ]
            ]
        , div [ class "row" ]
            [ div
                [ style "margin" "10px"
                , style "position" "relative"
                , style "background" "#273d52"
                , style "border-radius" "5px"
                ]
                [ div
                    [ style "background" "#4c86e5"
                    , style "height" "5px"
                    , style "border-radius" "5px"
                    , style "width" customerFeeShare
                    ]
                    [ div
                        [ style "position" "absolute"
                        , style "top" "-5px"
                        , style "left" "50%"
                        , style "width" "5px"
                        , style "height" "15px"
                        , style "background-color" "#c5c5c5"
                        ]
                        []
                    ]
                ]
            ]
        , div [ class "row" ]
            [ div
                [ class "col-xs-4"
                , style "color" "#4c86e5"
                , style "font-weight" "bold"
                , style "font-size" "1.1em"
                ]
                [ percents customer_fee_variable
                    |> String.replace "\u{00A0}" ""
                    |> text
                ]
            , div [ class "col-xs-4 text-center" ]
                [ strong []
                    [ percents maximum_interest_rate.below_3000
                        |> String.replace "\u{00A0}" ""
                        |> text
                    ]
                , br [] []
                , text "frais max"
                ]
            , div
                [ class "col-xs-4 text-right"
                , style "color" "#273d52"
                , style "font-weight" "bold"
                , style "font-size" "1.1em"
                ]
                [ percents merchant_fee_variable
                    |> String.replace "\u{00A0}" ""
                    |> text
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ p [ style "padding-top" "20px" ]
                    [ u [] [ text "Exemple :" ]
                    , text " Pour l'achat de "
                    , span
                        [ style "color" "#4c86e5"
                        , style "font-weight" "bold"
                        ]
                        [ text <| "300€, votre client paiera\u{00A0}" ++ euros exampleClientFee ]
                    , text " de frais et "
                    , span
                        [ style "color" "#5273d52"
                        , style "font-weight" "bold"
                        ]
                        [ text <| "vous paierez\u{00A0}" ++ euros exampleMerchantFee ]
                    ]
                ]
            ]
        ]
