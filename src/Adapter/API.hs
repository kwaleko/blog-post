{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module Adapter.API where

--import Data.Either
import Control.Monad.Reader
import Control.Monad.Except
import Data.Aeson(ToJSON(..)
                 ,FromJSON(..)
                 ,Value(..)
                 ,object
                 ,(.=))
import Data.Proxy(Proxy(..))
import Data.ByteString.Lazy.Char8(pack)
import Database.HDBC.Sqlite3(Connection)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.Cors
import Servant.Client
import Servant.Server
import Servant.API

import qualified Lib           as L
import qualified Core.Types    as T
import qualified Core.Users    as U
import qualified Core.Articles as A
import qualified Adapter.SQL   as S


type API
   =     "api" :> "users"    :> "register"                    :> ReqBody '[JSON] T.Register      :> Post '[JSON] T.UserId
  :<|>   "api" :> "users"    :> "login"                       :> ReqBody '[JSON] T.Auth          :> Post '[JSON] T.UserId
  :<|>   "api" :> "articles" :> Capture "userid" T.UserId     :> ReqBody '[JSON] T.CreateArticle :> Post '[JSON] T.Article
  :<|>   "api" :> "articles" :> Capture "slug" T.Slug         :> Get '[JSON] T.Article
  :<|>   "api" :> "articles" :> "parseArticle"                :> ReqBody '[JSON] T.ArticleBody   :> Post '[JSON] T.PArticleBody
  :<|>   "api" :> "articles" :> Get '[JSON]  [T.Article]

parseArticleHandler :: T.ArticleBody -> Handler T.PArticleBody
parseArticleHandler content = return $ A.pArticleBody content

registerHandler :: Connection -> T.Register ->  Handler T.UserId
registerHandler conn usr = do
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

createArticleHandler :: Connection -> T.UserId -> T.CreateArticle ->Handler T.Article --Handler ( Headers '[Header "Access-Control-Request-Method"  String]  T.Article)
createArticleHandler conn uId article = do
  result <- liftIO $ runReaderT ( runExceptT  $ A.createArticle uId article ) conn
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return  article

getArticleHandler :: Connection -> T.Slug -> Handler T.Article
getArticleHandler conn slug = do
  result <- liftIO $ runReaderT (runExceptT $ A.getArticle slug) conn
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return article

getArticlesHandler :: Connection -> Handler  [T.Article]
getArticlesHandler conn = do
  result <- liftIO $ runReaderT (runExceptT A.getArticles) conn
  case result of
    Left err -> throwError $ liftErr err
    Right articles -> return  articles

appServer :: Connection -> Server API
appServer conn =
  registerHandler conn      :<|>
  loginHandler conn         :<|>
  createArticleHandler conn :<|>
  getArticleHandler conn    :<|>
  parseArticleHandler       :<|>
  getArticlesHandler conn

appAPI :: Proxy API
appAPI = Proxy :: Proxy API

runServer :: IO ()
runServer = do
  conn <- S.connect
  run 8001 (app conn)

app conn
  = cors ( const $ Just (simpleCorsResourcePolicy  { corsRequestHeaders = ["Content-Type"] }) )
         (serve appAPI (appServer conn))

instance FromJSON T.Register
instance FromJSON T.Auth
instance FromJSON T.CreateArticle
instance FromJSON T.Article
instance FromJSON T.ArticleBody
instance FromJSON T.PArticleBody

instance ToJSON T.Register
instance ToJSON T.Auth
instance ToJSON T.CreateArticle
instance ToJSON T.Article
instance ToJSON T.ArticleBody
instance ToJSON T.PArticleBody

liftErr :: (Show a) =>  a -> ServantErr
liftErr err = err300 {errBody = pack $ show err}
