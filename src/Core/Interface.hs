module Interface where

import   Core.Types

class (Monad m) => ArticleRepo m where
  addArticle :: CreateArticle -> Slug -> UserId -> m ()
  updateArticleBySlug :: Slug -> UpdateArticle -> Slug -> m ()
  isArticleOwnedByUser :: UserId -> Slug -> m (Maybe Bool)
  findArticles :: QueryArticleBy -> m [Article]

class (Monad m) => UserRepo m where
  addUser :: Register ->  m ()
  isEmailExists :: Email -> m Bool
  isUserNameExists :: UserName -> m Bool
  findUserByAuth :: Auth -> m (Maybe UserId)
  --findUserById :: UserId -> m (Maybe (WithId User))
