module Main where

--import Lib
import Adapter.API(runAPIServer
                  ,runStaticServer)


main :: IO ()
main = do
  runStaticServer
  runAPIServer
