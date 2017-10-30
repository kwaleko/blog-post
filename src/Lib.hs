module Lib
    (
    ) where

import Core.Types as T
import Core.ManageArticles
import Core.ManageUsers

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
