module Core.Types where

import Control.Monad.Except
import Data.Maybe
import Data.Int(Int64)

-- General --

data WithId a = WithId
  {
   id    :: Int64
  ,model :: a
  }

type UserName = String
type Email    = String
type UserId = Int64

--  Register use-case --

data Register = Register
  {
   registerEmail    :: String
  ,registerUserName :: String
  ,registerPassword :: String
  } deriving(Eq,Show)

data RegisterError
  = RegisterErrorEmailTaken Email
  | RegisterErrorUserNameTaken UserName

-- Log In use-case --

data Auth = Auth
  {
     authEmail    :: String
    ,authPassword :: String
  } deriving(Eq,Show)

data AuthError
  = AuthErrorBadAuthentication
  | AuthErrorUserNotFound UserName

class (Monad m) => UserRepo m where
  register :: Register -> ExceptT RegisterError m ()
  findUserByAuth :: Auth -> m (Maybe (WithId User))
  findUserById :: UserId -> m (Maybe (WithId User))

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



class (Monad m) => ArticleRepo m where
  addArticle    :: Article -> m ()
  deleteArticle :: Article -> m ()
  updateArticle :: UpdateArticle -> m ()
