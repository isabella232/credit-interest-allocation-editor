module Events exposing (onBlurWithTargetValue)

import Html.Events exposing (on, targetValue)
import Json.Decode as Json


onBlurWithTargetValue : (String -> msg) -> Attribute msg
onBlurWithTargetValue tagger =
    on "blur" (Json.map tagger targetValue)
