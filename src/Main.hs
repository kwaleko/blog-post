{-# LANGUAGE OverloadedStrings #-}
module Main where

import Elm
import Servant.Elm
import Data.Proxy

import qualified Core.Types as T
import qualified Adapter.API as API

main :: IO ()
main = undefined

--Generate ELM Types
spec :: Spec
spec =
  Spec
    ["", "Types"]
    (defElmImports
             : toElmTypeSource    (Proxy :: Proxy T.Register)
             : toElmDecoderSource (Proxy :: Proxy T.Register)
             : toElmEncoderSource (Proxy :: Proxy T.Register)
             : toElmTypeSource    (Proxy :: Proxy T.Article)
             : toElmDecoderSource (Proxy :: Proxy T.Article)
             : toElmEncoderSource (Proxy :: Proxy T.Article)
             : toElmTypeSource    (Proxy :: Proxy T.CreateArticle)
             : toElmDecoderSource (Proxy :: Proxy T.CreateArticle)
             : toElmEncoderSource (Proxy :: Proxy T.CreateArticle)
             : toElmTypeSource    (Proxy :: Proxy T.Auth)
             : toElmDecoderSource (Proxy :: Proxy T.Auth)
             : toElmEncoderSource (Proxy :: Proxy T.Auth)
             : generateElmForAPIWith elmOptions  (Proxy :: Proxy API.API)

    )
elmOptions :: ElmOptions
elmOptions =ElmOptions {
  urlPrefix = Static "http://localhost:8001"
  ,elmExportOptions = Elm.defaultOptions
  ,emptyResponseElmTypes = []
  ,stringElmTypes = []
            }



genTypes:: IO ()
genTypes = specsToDir [spec] "/Users/lambda/development/blog-post/src/Adapter/FrontEnd/"
