module Core.Articles where

import Control.Monad.Except

import Core.Types as T
import Core.Interfaces as I

-- Manage Articles --
updateArticle :: (I.ArticleRepo m) => T.UserId -> T.UpdateArticle-> T.Slug -> ExceptT T.ArticleError m T.Article
updateArticle uId article slug = do
  validateArticleOwnedBy uId slug
  newSlug <- case T.updateArticleTitle article of
    Nothing -> return slug
    Just newTitle -> return $ genSlug slug
  lift $ T.updateArticleBySlug slug article newSlug
  getArticle newSlug

validateArticleOwnedBy :: (I.ArticleRepo m) => T.UserId -> T.Slug  -> ExceptT T.ArticleError m ()
validateArticleOwnedBy uId slug = do
  result <-lift $ T.isArticleOwnedByUser uId slug
  case result of
    Nothing -> throwError $ T.ArticleErrorNotFound slug
    (Just False) -> throwError $ T.ArticleErrorNotAllowed slug
    _ -> return  ()

-- genSlug should be updated to add datetime with user id to the new slug
-- in order to prevent the slug to be duplicated. Ex: 12-176844600-my-title-post
genSlug :: T.Title -> T.Slug
genSlug  = map (\c -> if c == ' ' then '-' else c)

createArticle :: (I.ArticleRepo m) => T.UserId -> T.CreateArticle -> ExceptT T.ArticleError m T.Article
createArticle uId article = do
  let newSlug = genSlug $ createArticleTitle article
  lift $ T.addArticle article newSlug uId
  getArticle newSlug

getArticle :: (I.ArticleRepo m) => Slug -> ExceptT T.ArticleError m T.Article
getArticle slug = do
  result <- lift $ T.findArticles (QueryArticleBySlug slug)
  case result of
    [] -> throwError $ ArticleErrorNotFound slug
    lst -> return $ head lst

getArticles :: (I.ArticleRepo m) =>  ExceptT T.ArticleError m [T.Article]
getArticles = lift $ T.findArticles All

deleteArticle :: (I.ArticleRepo m) => T.UserId -> T.Slug -> ExceptT T.ArticleError m ()
deleteArticle uId slug = do
  validateArticleOwnedBy uId slug
  lift $ T.deleteArticle slug
