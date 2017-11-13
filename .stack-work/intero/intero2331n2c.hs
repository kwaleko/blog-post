{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module API where

import Data.Either
import Control.Monad.Except
import Data.Aeson(ToJSON(..),FromJSON(..),Value(..),object,(.=))
import Data.Proxy(Proxy(..))
import Servant.Client
import Servant.Server
import Servant.API
import Servant

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

instance T.UserRepo IO where
   addUser = undefined

registerHandler :: (T.UserRepo m) => T.Register ->  Handler T.UserId
registerHandler usr = do
    result <- runExceptT  $ U.register usr
    case result of
      Left err -> throwError $ liftErr err
      Right uId -> return uId

liftErr :: T.UserError -> ServantErr
liftErr = undefined

instance ToJSON T.Register where
 -- toJSON :: T.Register -> Value
  toJSON usr = object
   [
    "registerUserName" .= toJSON ( T.registerUserName usr)
    ,"registerEmail" .= toJSON ( T.registerEmail usr )
    ,"registerPassword" .= toJSON ( T.registerPassword usr)
   ]

instance ToJSON T.Auth where
  toJSON auth = object
     [
      "authEmail" .= toJSON (T.authEmail auth)
      ,"authPass" .= toJSON (T.authPassword auth)
    ]

instance ToJSON T.CreateArticle where
  toJSON article = object
    [
      "createArticleTitle" .= toJSON (T.createArticleTitle article)
      ,"createArticleBody" .= toJSON (T.createArticleBody article)
      ,"createArticleTags" .=toJSON (T.createArticleTags article)
    ]

instance ToJSON T.Article where
  toJSON article = object
    [
      "articleSlug" .= toJSON (T.articleSlug article)
      ,"articleTitle" .= toJSON (T.articleTitle article)
      ,"articleBody" .= toJSON (T.articleBody article)
      ,"articleAuthor" .= toJSON (T.articleAuthor article)
      ,"articleTags" .= toJSON (T.articleTags article)
    ]
