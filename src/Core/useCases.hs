module UseCases where

import Control.Monad.Except

import Core.Types as T


updateArticle ::
  (T.ArticleRepo m) =>
     T.UserId
  -> T.UpdateArticle
  -> T.Slug
  -> ExceptT T.UpdateArticleError m T.Article
updateArticle userId article slug = undefined

validateArticleOwnedBy :: (T.ArticleRepo m) => T.UserId -> T.Slug  -> ExceptT T.UpdateArticleError m ()
validateArticleOwnedBy uId slug = do
  result <-lift $ T.isArticleOwnedByUser uId slug
  case result of
    Nothing -> throwError $ T.UpdateArticleErrorNotFound slug
    (Just False) -> throwError $ T.UpdateArticleErrorNotAllowed slug
    _ -> return  ()
