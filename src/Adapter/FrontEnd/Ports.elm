port module Ports exposing (..)

import Json.Encode exposing (Value)

port storeToken : Int -> Cmd msg

port clearToken : String -> Cmd msg

port getToken : (Value ->  msg) -> Sub msg
