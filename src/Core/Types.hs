module Core.Types where

import Control.Monad.Except
import Data.Maybe
import Data.Int(Int64)

-- General --

data WithId a = WithId
  {
   id    :: Int64
  ,model :: a
  }deriving (Eq,Show)

type UserName = String
type Email    = String
type UserId = Int64
type Tag = String
type Slug = String

-- Entity for Register use-case --

data Register = Register
  {
   registerEmail    :: String
  ,registerUserName :: String
  ,registerPassword :: String
  } deriving(Eq,Show)

data RegisterError
  = RegisterErrorEmailTaken Email
  | RegisterErrorUserNameTaken UserName
  deriving (Eq,Show)

-- Entity for Log In use-case --

data Auth = Auth
  {
     authEmail    :: String
    ,authPassword :: String
  } deriving(Eq,Show)

data AuthError
  = AuthErrorBadAuthentication
  | AuthErrorUserNotFound UserName
  deriving (Eq,Show)

class (Monad m) => UserRepo m where
  register :: Register -> ExceptT RegisterError m ()
  findUserByAuth :: Auth -> m (Maybe (WithId User))
  findUserById :: UserId -> m (Maybe (WithId User))

-- Entity for Create Article use-case --

data CreateArticle = CreateArticle
   {
     createArticleTitle :: String
    ,createArticleBody :: String
    ,createArticleTags :: [Tag]
    }deriving(Eq,Show)

-- Entity for Update Article use-case --

data UpdateArticle = UpdateArticle
  {
    updateArticleTitle :: Maybe String,
    updateArticleBody :: Maybe String
  }deriving (Eq,Show)

data UpdateArticleError
  = UpdateArticleErrorNotAllowed Slug
  deriving(Eq,Show)

-- Entity for Get Articles use-case --
data Article = Article
  {articleSlug :: String
  ,articleTitle :: String
  ,articleBody :: String
  --,articleCreatedAt :: UTCDateTime
  --,articleUpdatedAt :: UTCDateTime
  ,articleAuthor :: UserName
  ,articleTags :: [Tag]
  }

class (Monad m) => ArticleRepo m where
  addArticle :: CreateArticle -> Slug -> UserId -> m ()
  updateArticle :: Slug -> UpdateArticle -> Slug -> m ()
  isArticleOwnedByUser :: UserId -> Slug -> m (Maybe Bool)
  findArticles :: m [Article]
