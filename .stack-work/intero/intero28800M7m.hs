{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
--{-# LANGUAGE OverloadedStrings #-}
module API where

import Servant.Client
import Servant.Server
import Servant.API
import Data.Aeson

import qualified Core.Types as T
import qualified Core.ManageUsers as U

type API
   =   UsersAPI
  :<|> ArticlesAPI

type UsersAPI
   =   "api" :> "users" :> "register" :> ReqBody '[JSON] T.Register :> Get '[JSON] T.UserId -- Post /api/users/register
  :<|> "api" :> "users" :> "login" :> ReqBody '[JSON] T.Auth :> Get '[JSON] T.UserId -- Get /api/users/login

type ArticlesAPI
  =    "api" :> "articles" :> Capture "userid" T.UserId :> ReqBody '[JSON] T.CreateArticle :> Post '[JSON] T.Article --Post /api/articles/:userid/
  :<|> "api" :> "articles" :> Capture "slug" T.Slug :> Get '[JSON] T.Article -- Get /api/articles/:slug/
  :<|> "api" :> "articles" :> Get '[JSON] [T.Articles] -- Get /api/articles/

registerHandler :: T.Register -> Handler T.UserId
registerHandler usr = lift $ U.register usr

loginHandler :: T.Auth -> Handler T.UserId
loginHandler  = lift U.login

createArticleHandler :: T.UserId -> T.CreateArticle -> Handler T.Article
createArticleHandler uId article = lift $ U.createArticle uId article

getArticleHandler :: T.Slug -> Handler T.Article
getArticleHandler = lift U.getArticle

getArticlesHandler :: Handler T.Article
getArticlesHandler = lift U.getArticles
--usersAPI :: Proxy UsersAPI
--usersAPI = Proxy :: Proxy UsersAPI


server :: Server UsersAPI
server=
  fetchUserHandler         :<|>
  createUserHandler        :<|>
  fetchArticlesHandler     :<|>
  createArticleHandler     :<|>
  fetchArticleByIdHandler  :<|>
  fetchArticlesByTagHandler
