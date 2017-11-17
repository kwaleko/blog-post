port module Ports exposing (..)

import Json.Encode exposing (Value)

port storeToken : Maybe Int -> Cmd msg

port clearToken : String -> Cmd msg

port onTokenChange : (Value ->  msg) -> Sub msg
