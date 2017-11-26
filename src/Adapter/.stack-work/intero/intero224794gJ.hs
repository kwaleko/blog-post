{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module Adapter.API where

--import Data.Either
import Control.Monad.Reader
import Control.Monad.Except
import Data.Aeson(ToJSON(..),FromJSON(..),Value(..),object,(.=))
import Data.Proxy(Proxy(..))
import Data.ByteString.Lazy.Char8(pack)
import Network.Wai.Handler.Warp (run)
import Servant.Client
import Servant.Server
import Servant.API

import qualified Lib as L
import qualified Core.Types as T
import qualified Core.Users as U
import qualified Core.Articles as A
import qualified Adapter.SQL  (connect)


type API
   =   "api" :> "users" :> "register" :> ReqBody '[JSON] T.Register :> Post '[JSON] T.UserId -- Post /api/users/register
  :<|> "api" :> "users" :> "login" :> ReqBody '[JSON] T.Auth :> Get '[JSON] T.UserId -- Get /api/users/login
  :<|> "api" :> "articles" :> Capture "userid" T.UserId :> ReqBody '[JSON] T.CreateArticle :> Post '[JSON] T.Article --Post /api/articles/:userid/
  :<|> "api" :> "articles" :> Capture "slug" T.Slug :> Get '[JSON] T.Article -- Get /api/articles/:slug/
  :<|> "api" :> "articles" :> Get '[JSON] [T.Article] -- Get /api/articles/

registerHandler :: Connection -> T.Register ->  Handler T.UserId
registerHandler conn usr = do
    result <-liftIO $ runExceptT  $ U.register usr
    case result of
      Left err -> throwError $ liftErr err
      Right uId -> return uId

registerHandler' :: Connection -> T.Register ->  Handler T.UserId
registerHandler' conn usr = do
    result <-liftIO $  runReaderT(runExceptT $ U.register usr) conn
    case result of
      Left err -> throwError $ liftErr err
      Right uId -> return uId

loginHandler :: Connection -> T.Auth -> Handler T.UserId
loginHandler conn auth = do
  result <- liftIO $runReaderT ( runExceptT $ U.login auth) conn
  case result of
    Left err -> throwError $ liftErr err
    Right uId -> return uId

createArticleHandler :: Connection -> T.UserId -> T.CreateArticle -> Handler T.Article
createArticleHandler conn uId article = do
  result <- liftIO $ runReaderT ( runExceptT  $ A.createArticle uId article ) conn
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return article

getArticleHandler :: Connection -> T.Slug -> Handler T.Article
getArticleHandler conn slug = do
  result <- liftIO $ runReaderT (runExceptT $ A.getArticle slug) conn
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return article

getArticlesHandler :: Connection -> Handler [T.Article]
getArticlesHandler conn = do
  result <- liftIO $ runReaderT (runExceptT A.getArticles) conn
  case result of
    Left err -> throwError $ liftErr err
    Right articles -> return articles

appServer :: Connection -> Server API
appServer conn =
  registerHandler conn      :<|>
  loginHandler conn         :<|>
  createArticleHandler conn :<|>
  getArticleHandler conn    :<|>
  getArticlesHandler conn

appAPI :: Proxy API
appAPI = Proxy :: Proxy API

runServer :: IO ()
runServer = do
  conn <- connect
  run 8000 (serve appAPI (appServer conn))



liftErr :: (Show a) =>  a -> ServantErr
liftErr err = err300 {errBody = pack $ show err}
