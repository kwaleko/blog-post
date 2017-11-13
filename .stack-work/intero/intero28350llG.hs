module UseCases where

import Control.Monad.Except

import Core.Types as T

-- Articles
updateArticle :: (T.ArticleRepo m) => T.UserId -> T.UpdateArticle-> T.Slug -> ExceptT T.ArticleError m T.Article
updateArticle uId article slug = do
  validateArticleOwnedBy uId slug
  newSlug <- case T.updateArticleTitle article of
    Nothing -> return slug
    Just newTitle -> return $ genSlug slug
  lift $ T.updateArticleBySlug slug article newSlug
  getArticle newSlug

validateArticleOwnedBy :: (T.ArticleRepo m) => T.UserId -> T.Slug  -> ExceptT T.ArticleError m ()
validateArticleOwnedBy uId slug = do
  result <-lift $ T.isArticleOwnedByUser uId slug
  case result of
    Nothing -> throwError $ T.ArticleErrorNotFound slug
    (Just False) -> throwError $ T.ArticleErrorNotAllowed slug
    _ -> return  ()

-- genSlug should be updated to add datetime with user id to the new slug
-- in order to prevent the slug to be duplicated. Ex: 12-176844600-my-title-post
genSlug :: T.Title -> T.Slug
genSlug title = undefined

getArticle :: (T.ArticleRepo m) => Slug -> ExceptT T.ArticleError m T.Article
getArticle slug = do
  result <- lift $ T.findArticles (QueryArticleBySlug slug)
  case result of
    [] -> throwError $ ArticleErrorNotFound slug
    lst -> return $ head lst

getArticles :: (ArticleRepo m) =>  ExceptT T.ArticleError m [T.Article]
getArticles = lift $ T.findArticles All
