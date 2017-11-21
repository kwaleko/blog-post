{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
module Core.Types where

import Elm
import GHC.Generics
import Data.Text


type UserName = String
type Email    = String
type UserId   = Int
type Tag      = String
type Slug     = String
type Title    = String
data NoContent = NoContent
  deriving (Generic,ElmType)

-- Entity for Register use-case --

data Register = Register
  {registerEmail    :: String
  ,registerUserName :: String
  ,registerPassword :: String
  } deriving(Eq,Show,Generic,ElmType)

-- Entity for Log In use-case --

data Auth = Auth
  {authEmail    :: String
  ,authPassword :: String
  } deriving(Eq,Show,Generic,ElmType)

data UserError
  = AuthErrorBadAuthentication
  | RegisterErrorEmailTaken Email
  | RegisterErrorUserNameTaken UserName
  deriving (Eq,Show,Generic,ElmType)

-- Entity for Create Article use-case --

data CreateArticle = CreateArticle
   { createArticleTitle :: Title
   ,createArticleBody   :: String
   ,createArticleTags   :: [Tag]
   }deriving(Eq,Show,Generic,ElmType)

-- Entity for Update Article use-case --

data UpdateArticle = UpdateArticle
  {updateArticleTitle :: Maybe String
  ,updateArticleBody  :: Maybe String
  }deriving (Eq,Show,Generic,ElmType)

data ArticleError
  = ArticleErrorNotAllowed Slug
  | ArticleErrorNotFound Slug
  deriving(Eq,Show)

-- Entity for Get Articles use-case --

data Article = Article
  {articleSlug      :: String
  ,articleTitle     :: String
  ,articleBody      :: String
  ,articleAuthor    :: UserName
  ,articleTags      :: [Tag]
  ,parsedArticle    ::  [(Text,String)]
  ,articleCreatedAt :: String
  ,articleUpdatedAt :: String
  } deriving (Eq,Show,Generic,ElmType)

-- Types related to the Parser module --
data QueryArticleBy
  = All
  | QueryArticleBySlug Slug

data Style
  = Normal
  | Bold
  | Italic
  | URL String
  | Heading
  | Mark
  | Code
  deriving(Eq,Show,Generic)
