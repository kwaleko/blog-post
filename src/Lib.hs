{-#Language FlexibleInstances#-}
module Lib
    (
    ) where

import Database.HDBC.Sqlite3(Connection)
import qualified Adapter.Sqlite as S
import Control.Monad.Reader
import qualified Core.Types as T
import qualified Core.Interfaces as I
import Core.Articles
import Core.Users
import qualified  Adapter.Sqlite as S


{- instance I.UserRepo IO where
   addUser = undefined
   isEmailExists = undefined
   isUserNameExists =undefined
   findUserByAuth = undefined

instance I.ArticleRepo IO where
  addArticle = undefined
  findArticles = undefined
  isArticleOwnedByUser = undefined
  updateArticleBySlug = undefined
  deleteArticle = undefined -}

instance I.ArticleRepo (ReaderT Connection IO) where
  addArticle = S.createArticle
  findArticles T.All = S.findArticles
  findArticles (T.QueryArticleBySlug slug) = S.findArticle slug
  isArticleOwnedByUser = S.isArticleOwnedByUser
  updateArticleBySlug = undefined
  deleteArticle = undefined

instance I.UserRepo (ReaderT Connection IO ) where
  addUser = S.register
  isEmailExists = S.isEmailExists
  isUserNameExists = S.isUserNameExists
  findUserByAuth = S.findUserByAuth
