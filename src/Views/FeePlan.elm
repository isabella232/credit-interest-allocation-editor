module Views.FeePlan exposing (show)

import Data.FeePlan exposing (FeePlan)
import Data.L10n exposing (L10n)
import Data.Msg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Input.Float as MaskedPercentage
import Views.Svg as Svg
import Views.Utils exposing (euros, percents)


show : L10n -> Bool -> ( FeePlan, FeePlan ) -> Html Msg
show l10n is_sending ( original_fee_plan, { installments_count, merchant_fee_variable, merchant_fee_fixed, customer_fee_variable, customer_fee_fixed, capped, maximum_interest_rate, max_purchase_amount } as fee_plan ) =
    let
        fee_plan_id =
            String.fromInt installments_count
                |> (++) "fee-plan-"
    in
    div []
        [ h4 []
            [ text <| String.replace "{{installments_count}}" (String.fromInt installments_count) l10n.fee_plan_title
            , text <|
                if fee_plan.kind == "pos" then
                    l10n.fee_plan_title_pos_suffix

                else
                    ""
            ]
        , p []
            [ span []
                [ strong [] [ text <| l10n.merchant_fees_label ++ " " ]
                , show_merchant_fees l10n merchant_fee_variable merchant_fee_fixed |> text
                ]
            , br [] []
            , span []
                [ strong [] [ text <| l10n.customer_fees_label ++ " " ]
                , show_fees l10n customer_fee_variable customer_fee_fixed |> text
                , if capped then
                    text <| " " ++ l10n.deducted_from_merchant_fees

                  else
                    text ""
                ]
            ]
        , if customer_fee_fixed /= 0 then
            text ""

          else
            div [ class "row", style "min-height" "230px" ]
                [ div [ class "col-sm-6", style "min-height" "160px" ]
                    [ strong [] [ text <| l10n.add_variable_customer_fees ]
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
                    , label [ for <| fee_plan_id ++ "-non" ] [ text l10n.no ]
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
                    , label [ for <| fee_plan_id ++ "-oui" ] [ text l10n.yes ]
                    , if customer_fee_variable == 0 then
                        text ""

                      else
                        showCustomerFeeVariableEditor l10n fee_plan
                    , if original_fee_plan /= fee_plan then
                        div [ class "text-center", style "margin" "20px" ]
                            [ button [ class "btn btn-primary", onClick (UpdateFeePlan fee_plan), disabled is_sending ] [ text l10n.save ]
                            ]

                      else
                        div [] []
                    ]
                , if customer_fee_variable == 0 then
                    text ""

                  else
                    showInterestPanel l10n fee_plan
                , showOver3000Message l10n fee_plan
                ]
        ]


euros_fees : String -> Int -> String
euros_fees label euroCents =
    euros euroCents ++ " " ++ label


percent_fees : String -> Int -> String
percent_fees label percentCents =
    percents percentCents ++ " " ++ label


show_fees : L10n -> Int -> Int -> String
show_fees l10n variable fixed =
    if fixed /= 0 then
        euros_fees l10n.per_transaction fixed

    else if variable /= 0 then
        percent_fees l10n.per_transaction variable

    else
        l10n.no_fee


show_merchant_fees : L10n -> Int -> Int -> String
show_merchant_fees l10n variable fixed =
    case ( fixed, variable ) of
        ( 0, 0 ) ->
            l10n.no_fee

        ( _, 0 ) ->
            euros_fees l10n.per_transaction fixed

        ( 0, _ ) ->
            percent_fees l10n.per_transaction variable

        ( _, _ ) ->
            percent_fees l10n.per_transaction variable ++ " + " ++ euros_fees l10n.per_transaction fixed


showCustomerFeeVariableEditor : L10n -> FeePlan -> Html Msg
showCustomerFeeVariableEditor l10n { installments_count, merchant_fee_variable, customer_fee_variable, maybe_customer_fee_variable } =
    let
        fee_plan_editor_id =
            String.fromInt installments_count
                |> (++) "fee-plan-"

        initialOptions =
            MaskedPercentage.defaultOptions (SetCustomerFeeVariable installments_count)

        inputOptions =
            { initialOptions
                | minValue = Just 0.01
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
            maybe_customer_fee_variable
        , label
            [ class "input-group-addon"
            , for fee_plan_editor_id
            ]
            [ text <| "% " ++ l10n.per_transaction ]
        ]


showInterestPanel : L10n -> FeePlan -> Html Msg
showInterestPanel l10n { customer_fee_variable, merchant_fee_variable, maximum_interest_rate } =
    let
        totalFees =
            customer_fee_variable + merchant_fee_variable

        maxFeeShare =
            (toFloat maximum_interest_rate.below_3000 / toFloat totalFees * 10000)
                |> round

        maxInterestBarPosition =
            maxFeeShare
                |> percents
                |> String.replace "," "."

        maxInterestTextPosition =
            maxFeeShare
                |> Basics.min 6700
                |> Basics.max 1900
                |> percents
                |> String.replace "," "."

        customerFeeShare =
            (toFloat customer_fee_variable / toFloat totalFees * 10000)
                |> round
                |> Basics.min 10000
                |> percents
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
        , style "padding" "20px"
        ]
        [ div [ class "row" ]
            [ div
                [ class "col-xs-6"
                , style "color" "#4c86e5"
                , style "font-weight" "bold"
                , style "font-size" "0.9em"
                ]
                [ text l10n.customer_fees ]
            , div
                [ class "col-xs-6 text-right"
                , style "color" "#273d52"
                , style "font-weight" "bold"
                , style "font-size" "0.9em"
                ]
                [ text l10n.merchant_fees ]
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
                    [ if maximum_interest_rate.below_3000 < totalFees then
                        div
                            [ style "position" "absolute"
                            , style "top" "-5px"
                            , style "left" maxInterestBarPosition
                            , style "width" "5px"
                            , style "height" "15px"
                            , style "background-color" "#c5c5c5"
                            ]
                            []

                      else
                        text ""
                    ]
                ]
            ]
        , div [ class "row", style "height" "50px" ]
            [ div
                [ class "col-xs-6"
                , style "color" "#4c86e5"
                , style "font-weight" "bold"
                , style "font-size" "1.1em"
                ]
                [ percents customer_fee_variable
                    |> text
                ]
            , if maximum_interest_rate.below_3000 < totalFees then
                div [ style "position" "absolute", style "left" maxInterestTextPosition ]
                    [ strong []
                        [ percents maximum_interest_rate.below_3000
                            |> text
                        ]
                    , br [] []
                    , a
                        [ title l10n.maximum_fees_explaination
                        , href "#"
                        , style "color" "black"
                        , style "text-decoration" "none"
                        , style "display" "inline-block"
                        , style "cursor" "help"
                        ]
                        [ text l10n.maximum_fees
                        , div
                            [ style "display" "inline-block"
                            , style "width" "16px"
                            , style "padding-left" "2px"
                            , style "color" "#4c86e5"
                            ]
                            [ Svg.info ]
                        ]
                    ]

              else
                text ""
            , div
                [ class <| "col-xs-6 text-right"
                , style "color" "#273d52"
                , style "font-weight" "bold"
                , style "font-size" "1.1em"
                ]
                [ percents merchant_fee_variable
                    |> text
                ]
            ]
        , let
            interpolated_variable_translation =
                l10n.example_sentence
                    |> String.replace "{{purchase_amount}}" (euros exampleAmount)
                    |> String.replace "{{customer_fee}}" (euros exampleClientFee)
                    |> String.replace "{{merchant_fee}}" (euros exampleMerchantFee)

            -- Before blue
            before_blue_split =
                String.split "<blue>" interpolated_variable_translation

            before_blue_part =
                before_blue_split
                    |> List.head
                    |> Maybe.withDefault ""

            remains_blue_part =
                before_blue_split
                    |> List.tail
                    |> Maybe.andThen List.head
                    |> Maybe.withDefault ""

            -- Inside blue part
            blue_split =
                String.split "</blue>" remains_blue_part

            blue_part =
                blue_split
                    |> List.head
                    |> Maybe.withDefault ""

            remains_after_blue_part =
                blue_split
                    |> List.tail
                    |> Maybe.andThen List.head
                    |> Maybe.withDefault ""

            -- Before strong
            before_strong_split =
                String.split "<strong>" remains_after_blue_part

            before_strong_part =
                before_strong_split
                    |> List.head
                    |> Maybe.withDefault ""

            remains_before_strong_part =
                before_strong_split
                    |> List.tail
                    |> Maybe.andThen List.head
                    |> Maybe.withDefault ""

            -- Inside strong
            strong_split =
                String.split "</strong>" remains_before_strong_part

            strong_part =
                strong_split
                    |> List.head
                    |> Maybe.withDefault ""

            -- After strong
            after_strong_part =
                strong_split
                    |> List.tail
                    |> Maybe.andThen List.head
                    |> Maybe.withDefault ""
          in
          div [ class "row" ]
            [ div
                [ class "col-xs-12"
                , style "font-size" "0.83em"
                ]
                [ p []
                    [ u [] [ text l10n.example_label ]
                    , text <| " " ++ before_blue_part ++ " "
                    , span
                        [ style "color" "#4c86e5"
                        , style "font-weight" "bold"
                        ]
                        [ text blue_part ]
                    , text <| " " ++ before_strong_part ++ " "
                    , span
                        [ style "color" "#5273d52"
                        , style "font-weight" "bold"
                        ]
                        [ text <| strong_part ]
                    , text <| " " ++ after_strong_part
                    ]
                ]
            ]
        ]


showOverRate : L10n -> FeePlan -> Html Msg
showOverRate l10n { installments_count, customer_fee_variable, maximum_interest_rate } =
    let
        over3000Amount =
            (toFloat installments_count / toFloat (installments_count - 1) * 300000)
                |> round
    in
    if customer_fee_variable > maximum_interest_rate.below_3000 then
        p [ style "margin" "10px" ]
            [ l10n.explain_over_3000
                |> String.replace "{{below_3000}}" (percents maximum_interest_rate.below_3000)
                |> String.replace "{{over_3000_amount}}" (euros over3000Amount)
                |> text
            ]

    else
        text ""


showOver3000Message : L10n -> FeePlan -> Html Msg
showOver3000Message l10n ({ max_purchase_amount, installments_count, customer_fee_variable, maximum_interest_rate } as fee_plan) =
    let
        customerFee =
            Basics.min customer_fee_variable maximum_interest_rate.below_3000

        over3000Amount =
            (toFloat installments_count / toFloat (installments_count - 1) * 300000)
                |> round

        over6000Amount =
            (toFloat installments_count / toFloat (installments_count - 1) * 600000)
                |> round
    in
    if customer_fee_variable > maximum_interest_rate.over_3000 && over3000Amount <= max_purchase_amount then
        div [ class "col-xs-12", style "background-color" "#f6f6f6", style "margin" "10px 0" ]
            [ showOverRate l10n fee_plan
            , p [ style "margin" "10px" ]
                [ l10n.explain_customer_fee_below_amount
                    |> String.replace "{{customer_rate}}" (percents customerFee)
                    |> String.replace "{{over_amount}}" (euros over3000Amount)
                    |> text
                , br [] []
                , if customer_fee_variable > maximum_interest_rate.over_6000 && over6000Amount <= max_purchase_amount then
                    l10n.explain_customer_fee_over_3000_and_over_6000
                        |> String.replace "{{over_3000_rate}}" (percents maximum_interest_rate.over_3000)
                        |> String.replace "{{over_3000_amount}}" (euros over3000Amount)
                        |> String.replace "{{over_6000_rate}}" (percents maximum_interest_rate.over_6000)
                        |> String.replace "{{over_6000_amount}}" (euros over6000Amount)
                        |> text

                  else
                    l10n.explain_customer_fee_over_rate_for_amount
                        |> String.replace "{{over_3000_rate}}" (percents maximum_interest_rate.over_3000)
                        |> String.replace "{{over_3000_amount}}" (euros over3000Amount)
                        |> text
                ]
            ]

    else if customer_fee_variable > maximum_interest_rate.over_6000 && over6000Amount <= max_purchase_amount then
        div [ class "col-xs-12", style "background-color" "#f6f6f6", style "margin" "10px 0" ]
            [ p [ style "margin" "10px" ]
                [ l10n.explain_customer_fee_below_amount
                    |> String.replace "{{customer_rate}}" (percents customer_fee_variable)
                    |> String.replace "{{over_amount}}" (euros over6000Amount)
                    |> text
                , br [] []
                , l10n.explain_customer_fee_over_rate_for_amount
                    |> String.replace "{{over_rate}}" (percents maximum_interest_rate.over_6000)
                    |> String.replace "{{over_amount}}" (euros over6000Amount)
                    |> text
                ]
            ]

    else
        text ""
