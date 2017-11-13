{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
--{-# LANGUAGE OverloadedStrings #-}
module API where


import Data.Int(Int64)
import Servant.Client
import Servant.Server
import Servant.API
import Data.Aeson

import qualified Core.Types as T

--type UserApi =
 -- "users" :> Capture "userid" Int :> Get '[JSON] Int
         --   "api" :> "user" :> Capture "userid" Int :> Get '[JSON] Int
type UsersAPI =
       "api" :> "users" :> Capture "userid" Int64 :> Get '[JSON] T.User
  :<|> "api" :> "users" :> ReqBody '[JSON] T.User :> Post '[JSON] Int64
  :<|> "api" :> "articles" :> Get '[JSON] [T.Article]
  :<|> "api" :> "articles" :> ReqBody '[JSON] T.Article :> Post '[JSON] Int64
  :<|> "api" :> "articles" :> Capture "articleid" Int64 :> Get '[JSON] T.Article
  :<|> "api" :> "articles" :> Capture "tag" String :> Get '[JSON] [T.Article]

usersAPI :: Proxy UsersAPI
usersAPI = Proxy :: Proxy UsersAPI

fetchUserHandler :: Int64 -> Handler  T.User
fetchUserHandler = undefined

createUserHandler :: T.User ->Handler Int64
createUserHandler = undefined

createArticleHandler :: T.Article ->Handler Int64
createArticleHandler = undefined

fetchArticlesHandler :: Handler [T.Article]
fetchArticlesHandler = undefined

fetchArticleByIdHandler :: Int64 -> Handler T.Article
fetchArticleByIdHandler id = undefined

fetchArticlesByTagHandler :: String -> Handler [T.Article]
fetchArticlesByTagHandler tag = undefined

server :: Server UsersAPI
server=
  fetchUserHandler         :<|>
  createUserHandler        :<|>
  fetchArticlesHandler     :<|>
  createArticleHandler     :<|>
  fetchArticleByIdHandler  :<|>
  fetchArticlesByTagHandler

--  runServer :: IO () 
--  runServer = run 8000 (serve usersAPI server)
