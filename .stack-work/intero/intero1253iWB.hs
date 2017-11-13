{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
--{-# LANGUAGE OverloadedStrings #-}
module API where

import Data.Either
import Control.Monad.Except
import Data.Aeson(ToJSON(..),FromJSON(..),Value)
import Data.Proxy(Proxy(..))
import Servant.Client
import Servant.Server
import Servant.API

import qualified Core.Types as T
import qualified Core.ManageUsers as U
import qualified Core.ManageArticles as A

type API
   =   UsersAPI
  :<|> ArticlesAPI

type UsersAPI
   =   "api" :> "users" :> "register" :> ReqBody '[JSON] T.Register :> Get '[JSON] T.UserId -- Post /api/users/register
  :<|> "api" :> "users" :> "login" :> ReqBody '[JSON] T.Auth :> Get '[JSON] T.UserId -- Get /api/users/login

type ArticlesAPI
  =    "api" :> "articles" :> Capture "userid" T.UserId :> ReqBody '[JSON] T.CreateArticle :> Post '[JSON] T.Article --Post /api/articles/:userid/
  :<|> "api" :> "articles" :> Capture "slug" T.Slug :> Get '[JSON] T.Article -- Get /api/articles/:slug/
  :<|> "api" :> "articles" :> Get '[JSON] [T.Article] -- Get /api/articles/

registerHandler :: (MonadIO m) =>  T.Register ->  Handler T.UserId
registerHandler usr = do
  result <- liftIO $ runExceptT  $ U.register usr
  case result of
    Left err -> throwError $ liftErr err
    Right uId -> return uId

liftErr :: T.UserError -> ServantErr
liftErr = undefined

{-loginHandler :: T.Auth -> Handler T.UserId
loginHandler  = lift U.login

 createArticleHandler :: T.UserId -> T.CreateArticle -> Handler T.Article
createArticleHandler uId article = lift $ A.createArticle uId article

getArticleHandler :: T.Slug -> Handler T.Article
getArticleHandler = lift A.getArticle

getArticlesHandler :: Handler T.Article
getArticlesHandler = lift A.getArticles
--usersAPI :: Proxy UsersAPI
--usersAPI = Proxy :: Proxy UsersAPI
server :: Server API
server
  = registerHandler
  :<|> loginHandler
  :<|> createArticleHandler
  :<|> getArticleHandler
  :<|> getArticlesHandler


appAPI :: Proxy API
appAPI = Proxy :: Proxy API

-- Derive JSON Instances
instance ToJSON T.CreateArticle where
  toJSON :: T.CreateArticle -> Value
  toJSON = undefined
-}
