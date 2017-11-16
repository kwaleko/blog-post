{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
module Core.Types where

-- proxy to be removed
import Data.Proxy
--import Data.Text(pack)

import Control.Monad.Except
import Data.Maybe
--import Data.Int(Int64)

-- Imports to generate ELM types from Haskell
import GHC.Generics
import Elm
-- General --

type UserName = String
type Email    = String
type UserId = Int
type Tag = String
type Slug = String
type Title = String

-- Entity for Register use-case --

data Register = Register
  {registerEmail    :: String
  ,registerUserName :: String
  ,registerPassword :: String
  } deriving(Eq,Show,Generic,ElmType)

-- code to be removed
--spec :: Spec
spec :: Spec
spec =
  Spec
    ["output", "Types"]
    [ "import Json.Decode exposing (..)"
    , "import Json.Decode.Pipeline exposing (..)"
    , toElmTypeSource (Proxy :: Proxy Register)
    , toElmDecoderSource (Proxy :: Proxy Register)
    ]

main :: IO ()
main = specsToDir [spec] "/Users/lambda/development/blog-post/src"

-- Entity for Log In use-case --

data Auth = Auth
  {authEmail    :: String
  ,authPassword :: String
  } deriving(Eq,Show)

data UserError
  = AuthErrorBadAuthentication
  | RegisterErrorEmailTaken Email
  | RegisterErrorUserNameTaken UserName
  deriving (Eq,Show)

class (MonadIO m) => UserRepo m where
  addUser :: Register ->  m ()
  isEmailExists :: Email -> m Bool
  isUserNameExists :: UserName -> m Bool
  findUserByAuth :: Auth -> m (Maybe UserId)
  --findUserById :: UserId -> m (Maybe (WithId User))

-- Entity for Create Article use-case --

data CreateArticle = CreateArticle
   { createArticleTitle :: Title
   ,createArticleBody :: String
   ,createArticleTags :: [Tag]
   }deriving(Eq,Show)

-- Entity for Update Article use-case --

data UpdateArticle = UpdateArticle
  {updateArticleTitle :: Maybe String
  ,updateArticleBody :: Maybe String
  }deriving (Eq,Show)

data ArticleError
  = ArticleErrorNotAllowed Slug
  | ArticleErrorNotFound Slug
  deriving(Eq,Show)


-- Entity for Get Articles use-case --
data QueryArticleBy
  = All
  | QueryArticleBySlug Slug

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
  updateArticleBySlug :: Slug -> UpdateArticle -> Slug -> m ()
  isArticleOwnedByUser :: UserId -> Slug -> m (Maybe Bool)
  findArticles :: QueryArticleBy -> m [Article]
  deleteArticle :: Slug -> m ()

-- Types related to the Parser module --
data Style
  = Normal
  | Bold
  | Italic
  | URL String
  | Heading
  | Mark
  | Code
  deriving(Eq,Show)