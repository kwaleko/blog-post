module Main where

-- import System.Directory(getHomeDirectory,doesDirectoryExist,createDirectory)
import Adapter.API(runServer,getHomeDirectory1,doesDirectoryExist1,createDirectory1)
import Data.Monoid((<>))
import Control.Monad(unless)
--import Control.Concurrent.ParallelIO.Global(parallel_)


main :: IO ()
main = do
  homeDir <- getHomeDirectory1
  let projPath = homeDir <> "/blogsite"
  let dbPath = homeDir <> "/blogsite" <> "/db"
  let filePath = homeDir <> "/blogsite" <> "/html"
  projDirCreated <- doesDirectoryExist1 projPath
  dbDirCreated <- doesDirectoryExist1 dbPath
  fileDirCreated <- doesDirectoryExist1 filePath
  unless projDirCreated $ createDirectory1 projPath
  unless dbDirCreated $  createDirectory1 dbPath
  unless fileDirCreated $ createDirectory1 filePath
 -- parallel_ [runAPIServer ( dbPath <> "/blog.db"),runStaticServer filePath]
  runServer (dbPath <> "/blog.db") filePath
