module Request.Alma exposing
    ( AlmaSettings
    , Endpoint(..)
    , Error(..)
    , Resource
    , endpointUrl
    , errorToString
    , expectJson
    , get
    , send
    )

import Http
import HttpBuilder
import Json.Decode as Decode


type alias Url =
    String


type alias Request a =
    HttpBuilder.RequestBuilder a


type Endpoint
    = MerchantFeePlan


type alias ErrorDetail =
    { errno : Int
    , message : String
    , code : Int
    , error : String
    }


type alias StatusCode =
    Int


type alias StatusMsg =
    String


type alias AlmaSettings =
    { apiServer : String
    , csrfToken : String
    }


{-| A type for all errors that the elm-client may return.
-}
type Error
    = ServerError StatusCode StatusMsg String
    | ServiceError StatusCode StatusMsg ErrorDetail
    | NetworkError (Http.Response String)


type alias Resource a =
    { endpoint : Endpoint
    , decoder : Decode.Decoder a
    }


endpointUrl : String -> Endpoint -> Url
endpointUrl baseUrl endpoint =
    let
        url =
            if String.endsWith "/" baseUrl then
                String.dropRight 1 baseUrl

            else
                baseUrl
    in
    case endpoint of
        MerchantFeePlan ->
            url ++ "/v1/me/fee-plans"


{-| Convert any Alma.Error to a string
-}
errorToString : Error -> String
errorToString error =
    case error of
        ServerError status message info ->
            String.fromInt status ++ " " ++ message ++ " " ++ info

        ServiceError status message detail ->
            String.fromInt status ++ " " ++ message ++ " " ++ detail.message

        NetworkError _ ->
            "NetworkError"


extractServiceError : StatusCode -> StatusMsg -> String -> Error
extractServiceError statusCode statusMsg body =
    case Decode.decodeString errorDecoder body of
        Ok errRecord ->
            ServiceError statusCode statusMsg errRecord

        Err err ->
            Decode.errorToString err
                |> ServerError statusCode statusMsg


errorDecoder : Decode.Decoder ErrorDetail
errorDecoder =
    Decode.map4 ErrorDetail
        (Decode.field "errno" Decode.int)
        (Decode.field "message" Decode.string)
        (Decode.field "code" Decode.int)
        (Decode.field "error" Decode.string)


{-| Extract an `Error` from an `Http.Error` or return the decoded value.
-}
expectJson : (Result Error a -> msg) -> Decode.Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadStatus_ { statusCode, statusText } body ->
                    Err <| extractServiceError statusCode statusText body

                Http.GoodStatus_ { statusCode, statusText } body ->
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err
                                (ServerError
                                    statusCode
                                    statusText
                                    ("failed decoding json: "
                                        ++ Decode.errorToString err
                                        ++ "\n\nBody received from server: "
                                        ++ body
                                    )
                                )

                anyError ->
                    NetworkError anyError |> Err


get : Resource a -> (Result Error a -> msg) -> AlmaSettings -> Request msg
get resource toMsg settings =
    endpointUrl settings.apiServer resource.endpoint
        |> HttpBuilder.get
        |> HttpBuilder.withCredentials
        |> HttpBuilder.withExpect (expectJson toMsg resource.decoder)


send : Request a -> Cmd a
send =
    HttpBuilder.request
