{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_blog_post (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/lambda/development/blog-post/.stack-work/install/x86_64-osx/lts-9.9/8.0.2/bin"
libdir     = "/Users/lambda/development/blog-post/.stack-work/install/x86_64-osx/lts-9.9/8.0.2/lib/x86_64-osx-ghc-8.0.2/blog-post-0.1.0.0-7vDs7UYTRC65AMqvGPRXQk"
dynlibdir  = "/Users/lambda/development/blog-post/.stack-work/install/x86_64-osx/lts-9.9/8.0.2/lib/x86_64-osx-ghc-8.0.2"
datadir    = "/Users/lambda/development/blog-post/.stack-work/install/x86_64-osx/lts-9.9/8.0.2/share/x86_64-osx-ghc-8.0.2/blog-post-0.1.0.0"
libexecdir = "/Users/lambda/development/blog-post/.stack-work/install/x86_64-osx/lts-9.9/8.0.2/libexec"
sysconfdir = "/Users/lambda/development/blog-post/.stack-work/install/x86_64-osx/lts-9.9/8.0.2/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "blog_post_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "blog_post_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "blog_post_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "blog_post_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "blog_post_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "blog_post_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
