module Core.Types where

data Article = Article
  {
    articleTitle :: String
   ,articleBody  :: String
   } deriving (Eq,Show)

data User = User
  {
    userUserName :: String
   ,userEmail    :: String
   ,userName     :: String
  } deriving(Eq,Show)

data WithId a = WithId
  {
     id    :: Int
    ,model :: a
  }deriving(Eq,Show)

class (Monad m) => ArticleRepo m where
  addArticle    :: Article -> m ()
  deleteArticle :: Article -> m ()

class (Monad m) => UserRepo m where
  addUser :: User -> m ()
