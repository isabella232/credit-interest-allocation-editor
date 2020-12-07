module Views.Utils exposing (euros, percents)

import Round


euros : Int -> String
euros cents =
    let
        amount =
            toFloat cents / 100
    in
    (Round.round 2 amount ++ "\u{00A0}€")
        |> String.replace "." ","


percents : Int -> String
percents bps =
    let
        percent =
            toFloat bps / 100
    in
    (Round.round 2 percent ++ "\u{00A0}%")
        |> String.replace "." ","
