{-# LANGUAGE OverloadedStrings #-}
module Main where

import Elm
import Data.Proxy

import qualified Core.Types as T

main :: IO ()
main = undefined

--Generate ELM Types
spec :: Spec
spec =
  Spec
    ["output", "Types"]
    [ "import Json.Decode exposing (..)"
    , "import Json.Decode.Pipeline exposing (..)"
    , toElmTypeSource (Proxy :: Proxy T.Register)
    , toElmDecoderSource (Proxy :: Proxy T.Register)
    ]

genTypes:: IO ()
genTypes = specsToDir [spec] "/Users/lambda/development/blog-post/src"
