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
import Network.Wai.Handler.Warp (run)
import Network.Wai(Request)
import Network.Wai.Application.Static(staticApp
                                     ,defaultWebAppSettings)
import Network.Wai.Middleware.Cors
-- import Servant.Client
--import Servant.Server
import Servant.API
import Database.HDBC.Sqlite3(Connection)
import Control.Concurrent.Async(race_)
import System.Directory(getHomeDirectory,doesDirectoryExist,createDirectory)


import qualified Lib           as L
import qualified Core.Types    as T
import qualified Core.Users    as U
import qualified Core.Articles as A
import qualified Adapter.Sqlite   as S
import qualified Effect as E

getHomeDirectory1= getHomeDirectory
doesDirectoryExist1 =doesDirectoryExist
createDirectory1 =createDirectory
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
    result <-liftIO $  E.runAppM conn $ runExceptT $ U.register usr
    case result of
      Left err -> throwError $ liftErr err
      Right uId -> return uId

loginHandler :: Connection -> T.Auth -> Handler T.UserId
loginHandler conn auth = do
  result <- liftIO $ E.runAppM conn $ runExceptT $ U.login auth
  case result of
    Left err -> throwError $ liftErr err
    Right uId -> return uId

createArticleHandler :: Connection -> T.UserId -> T.CreateArticle ->Handler T.Article --Handler ( Headers '[Header "Access-Control-Request-Method"  String]  T.Article)
createArticleHandler conn uId article = do
  result <- liftIO $ E.runAppM conn $ runExceptT  $ A.createArticle uId article
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return  article

getArticleHandler :: Connection -> T.Slug -> Handler T.Article
getArticleHandler conn slug = do
  result <- liftIO $ E.runAppM conn $ runExceptT $ A.getArticle slug
  case result of
    Left err -> throwError $ liftErr err
    Right article -> return article

getArticlesHandler :: Connection -> Handler  [T.Article]
getArticlesHandler conn = do
  result <- liftIO $ E.runAppM conn $ runExceptT A.getArticles
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

runStaticServer :: FilePath -> IO ()
runStaticServer filesPath = do
  let setting = defaultWebAppSettings filesPath
  run 80 $ staticApp setting

runAPIServer :: FilePath -> IO ()
runAPIServer dbPath = do
  conn <- S.connect dbPath
  S.migrateDB conn
  run 8001 (app conn)
------------------------------- worksapece --------------

fn :: Request -> Bool
fn _ = False

dispatch :: (Request -> Bool) -> Application -> Application -> Application
dispatch isMatch appYes appNo request respond =
    if isMatch request then
        appYes request respond
    else
        appNo request respond

runServer' :: Application -> IO ()
runServer' = undefined

runServer :: FilePath -> FilePath -> IO ()
runServer apiPath filePath = race_  (runAPIServer apiPath) (runStaticServer filePath)

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
