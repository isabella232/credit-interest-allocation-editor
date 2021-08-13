module Data.L10n exposing (L10n, decode, french)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias L10n =
    { fee_plan_title : String
    , fee_plan_title_pos_suffix : String
    , merchant_fees_label : String
    , customer_fees_label : String
    , per_transaction : String
    , no_fee : String
    , deducted_from_merchant_fees : String
    , add_variable_customer_fees : String
    , no : String
    , yes : String
    , save : String
    , customer_fees : String
    , merchant_fees : String
    , maximum_fees : String
    , maximum_fees_explaination : String
    , example_label : String
    , example_sentence : String
    , explain_over_3000 : String
    , explain_customer_fee_below_amount : String
    , explain_customer_fee_over_rate_for_amount : String
    , explain_customer_fee_over_3000_and_over_6000 : String
    }


french : L10n
french =
    { fee_plan_title = "Pour le paiement en {installments_count} fois"
    , fee_plan_title_pos_suffix = " - POS"
    , merchant_fees_label = "Vos frais :"
    , customer_fees_label = "Frais client :"
    , per_transaction = "par transaction"
    , no_fee = "aucun"
    , deducted_from_merchant_fees = "déduits des frais marchands"
    , add_variable_customer_fees = "Ajouter des frais clients variables ?"
    , no = "Non"
    , yes = "Oui"
    , save = "Enregistrer"
    , customer_fees = "Frais client"
    , merchant_fees = "Frais client"
    , maximum_fees = "frais max"
    , maximum_fees_explaination = "Les frais applicables aux clients sont limités par Alma, afin de rester en deçà du maximum légal autorisé. Ce maximum légal évoluant trimestriellement, les limites fixées par Alma pourront elles aussi changer."
    , example_label = "Exemple :"
    , example_sentence = "Pour un achat de {purchase_amount}, votre client paiera\u{00A0}{customer_fee} de frais et {split}vous paierez\u{00A0}{merchant_fee}"
    , explain_over_3000 = "Le taux configuré est supérieur au taux maximal légal autorisé. Sans modification de votre part, nous utiliserons le taux maximal légal en vigueur à la création du paiement. Ce taux, mis à jour trimestriellement par la Banque de France, est actuellement de\u{00A0}{below_3000} pour les paniers inférieurs à {over_3000_amount}."
    , explain_customer_fee_below_amount = "Les\u{00A0}{customer_rate}\u{00A0}de frais ne seront appliqués que pour les paniers inférieurs à\u{00A0}{over_amount}."
    , explain_customer_fee_over_rate_for_amount = "Nous sommes contraints d'appliquer\u{00A0}{over_3000_rate}\u{00A0}de frais client (maximum légal autorisé) pour les paniers supérieurs à\u{00A0}{over_3000_amount}."
    , explain_customer_fee_over_3000_and_over_6000 = "Nous sommes contraints d'appliquer\u{00A0}{over_3000_rate}\u{00A0}de frais client (maximum légal autorisé) pour les paniers supérieurs à\u{00A0}{over_3000_amount}\u{00A0}et inférieurs à\u{00A0}{over_6000_amount} puis\u{00A0}{over_6000_rate}\u{00A0}pour les paniers supérieurs à\u{00A0}{over_6000_amount}."
    }


decode : Decoder L10n
decode =
    Decode.succeed L10n
        |> required "fee_plan_title" Decode.string
        |> required "fee_plan_title_pos_suffix" Decode.string
        |> required "merchant_fees_label" Decode.string
        |> required "customer_fees_label" Decode.string
        |> required "per_transaction" Decode.string
        |> required "no_fee" Decode.string
        |> required "deducted_from_merchant_fees" Decode.string
        |> required "add_variable_customer_fees" Decode.string
        |> required "no" Decode.string
        |> required "yes" Decode.string
        |> required "save" Decode.string
        |> required "customer_fees" Decode.string
        |> required "merchant_fees" Decode.string
        |> required "maximum_fees" Decode.string
        |> required "maximum_fees_explaination" Decode.string
        |> required "example_label" Decode.string
        |> required "example_sentence" Decode.string
        |> required "explain_over_3000" Decode.string
        |> required "explain_customer_fee_below_amount" Decode.string
        |> required "explain_customer_fee_over_rate_for_amount" Decode.string
        |> required "explain_customer_fee_over_3000_and_over_6000" Decode.string
