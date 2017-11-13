{-#Language FlexibleInstances#-}
module Lib
    (
    ) where

import Database.HDBC.Sqlite3(Connection)
import qualified Adapter.Sqlite as S
import Control.Monad.Reader
import qualified Core.Types as T
import Core.Articles
import Core.Users
--import qualified  Adapter.SQl as S


instance T.UserRepo IO where
   addUser = undefined
   isEmailExists = undefined
   isUserNameExists =undefined
   findUserByAuth = undefined

instance T.ArticleRepo IO where
  addArticle = undefined
  findArticles = undefined
  isArticleOwnedByUser = undefined
  updateArticleBySlug = undefined
  deleteArticle = undefined

instance T.UserRepo (ReaderT Connection IO ) where
  addUser = S.register
  isEmailExists = S.isEmailExists
  isUserNameExists = S.isUserNameExists
  findUserByAuth = S.findUserByAuth
