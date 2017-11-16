port module Ports exposing (..)

import Json.Encode exposing (Value)

port storeToken : String -> Cmd msg

port onTokenChange : (Value ->  msg) -> Sub msg
