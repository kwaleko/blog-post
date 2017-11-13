module output.Types exposing (..)

import Json.Decode exposing (..)

import Json.Decode.Pipeline exposing (..)

type alias Register =
    { registerEmail : String
    , registerUserName : String
    , registerPassword : String
    }

decodeRegister : Decoder Register
decodeRegister =
    decode Register
        |> required "registerEmail" string
        |> required "registerUserName" string
        |> required "registerPassword" string