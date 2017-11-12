{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module API where

--import Data.Either
import Control.Monad.Reader
import Control.Monad.Except
import Data.Aeson(ToJSON(..),FromJSON(..),Value(..),object,(.=))
import Data.Proxy(Proxy(..))
import Data.ByteString.Lazy.Char8(pack)
import Servant.Client
import Servant.Server
import Servant.API
--import Servant

import qualified Lib as L
import qualified Core.Types as T
import qualified Core.Users as U
import qualified Core.Articles as A

type API
   =   "api" :> "users" :> "register" :> ReqBody '[JSON] T.Register :> Get '[JSON] T.UserId -- Post /api/users/register
  :<|> "api" :> "users" :> "login" :> ReqBody '[JSON] T.Auth :> Get '[JSON] T.UserId -- Get /api/users/login
  :<|> "api" :> "articles" :> Capture "userid" T.UserId :> ReqBody '[JSON] T.CreateArticle :> Post '[JSON] T.Article --Post /api/articles/:userid/
  :<|> "api" :> "articles" :> Capture "slug" T.Slug :> Get '[JSON] T.Article -- Get /api/articles/:slug/
  :<|> "api" :> "articles" :> Get '[JSON] [T.Article] -- Get /api/articles/

registerHandler :: T.Register ->  Handler T.UserId
registerHandler usr = do
    result <-liftIO $ runExceptT  $ U.register usr
    case result of
      Left err -> throwError $ liftErr err
      Right uId -> return uId

loginHandler :: T.Auth -> Handler T.UserId
loginHandler auth = do
  result <- liftIO $ runExceptT $ U.login auth
  case result of
    Left err -> throwError $ liftErr err
    Right uId -> return uId

createArticleHandler :: T.UserId -> T.CreateArticle -> Handler T.Article
createArticleHandler uId article = do
  result <- liftIO $  runExceptT  $ A.createArticle uId article
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return article

getArticleHandler :: T.Slug -> Handler T.Article
getArticleHandler slug = do
  result <- liftIO $ runExceptT $ A.getArticle slug
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return article

getArticlesHandler :: Handler [T.Article]
getArticlesHandler = do
  result <- liftIO $ runExceptT A.getArticles
  case result of
    Left err -> throwError $ liftErr err
    Right articles -> return articles

appServer :: Server API
appServer =
  registerHandler      :<|>
  loginHandler         :<|>
  createArticleHandler :<|>
  getArticleHandler    :<|>
  getArticlesHandler

appAPI :: Proxy API
appAPI = Proxy :: Proxy API

runServer :: IO ()
runServer = undefined -- run 3000 (serve appAPI appServer)

liftErr :: (Show a) =>  a -> ServantErr
liftErr err = err300 {errBody = pack $ show err}
