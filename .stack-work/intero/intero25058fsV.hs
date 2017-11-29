module Main where

import System.Directory(getHomeDirectory,doesDirectoryExist,createDirectory)
import Adapter.API(runAPIServer
                  ,runStaticServer)
import Data.Monoid((<>))
import Control.Monad(unless)


main :: IO ()
main = do
  homeDir <- getHomeDirectory
  let projPath = homeDir <> "/blogsite"
  let dbPath = homeDir <> "/blogsite" <> "/db"
  let filePath = homeDir <> "/blogsite" <> "/html"
  projDirCreated <- doesDirectoryExist projPath
  dbDirCreated <- doesDirectoryExist dbPath
  fileDirCreated <- doesDirectoryExist filePath
  unless projDirCreated $ createDirectory projPath
  unless dbDirCreated $  createDirectory dbPath
  unless fileDirCreated $ createDirectory filePath
  runAPIServer $ dbPath <> "/blog.db"
  runStaticServer filePath
