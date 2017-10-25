module Core.Types where

import Control.Monad.Except

data Register = Register
  {
   registerEmail    :: String
  ,registerUserName :: String
  ,registerPassword :: String
  } deriving(Eq,Show)

-- Article
data Article = Article
  {
    articleTitle :: String
   ,articleBody  :: String
   } deriving (Eq,Show)

data UpdateArticle = UpdateArticle
  {
     updateArticleTitle :: Maybe String
    ,updateArticleBody  :: Maybe String
  }deriving (Eq,Show)

-- User
data User = User
  {
    userUserName :: String
   ,userEmail    :: String
   ,userName     :: String
  } deriving(Eq,Show)

data UpdateUser = UpdateUser
  {
     updateUserName     :: Maybe String
    ,updateUserEmail    :: Maybe String
    ,updateUserPassword :: Maybe String
  }deriving (Eq,Show)

data WithId a = WithId
  {
     id    :: Int
    ,model :: a
  }deriving(Eq,Show)

class (Monad m) => ArticleRepo m where
  addArticle    :: Article -> m ()
  deleteArticle :: Article -> m ()
  updateArticle :: UpdateArticle -> m ()

class (Monad m) => UserRepo m where
  addUser :: Register -> ExpcepT UserError m ()
