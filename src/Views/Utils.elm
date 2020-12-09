module Views.Utils exposing (euros, percents)

import Round


euros : Int -> String
euros cents =
    let
        amount =
            toFloat cents / 100
    in
    (Round.round 2 amount ++ "€")
        |> String.replace "." ","
        |> String.replace ",00" ""


percents : Int -> String
percents bps =
    let
        percent =
            toFloat bps / 100
    in
    (Round.round 2 percent ++ "%")
        |> String.replace "." ","
