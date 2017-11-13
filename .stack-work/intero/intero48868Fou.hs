{-# LANGUAGE OverloadedStrings #-}
module ToJSON where

import Data.Aeson (ToJSON(..),object,(.=))

import qualified Core.Types as T

instance ToJSON T.Register where
 -- toJSON :: T.Register -> Value
  toJSON usr = object
   [
     "registerUserName" .= toJSON ( T.registerUserName usr)
    ,"registerEmail" .= toJSON ( T.registerEmail usr )
    ,"registerPassword" .= toJSON ( T.registerPassword usr)
   ]

instance ToJSON T.Auth where
  toJSON auth = object
     [
       "authEmail" .= toJSON (T.authEmail auth)
      ,"authPass" .= toJSON (T.authPassword auth)
    ]

instance ToJSON T.CreateArticle where
  toJSON article = object
    [
       "createArticleTitle" .= toJSON (T.createArticleTitle article)
      ,"createArticleBody" .= toJSON (T.createArticleBody article)
      ,"createArticleTags" .=toJSON (T.createArticleTags article)
    ]

instance ToJSON T.Article where
  toJSON article = object
    [
       "articleSlug" .= toJSON (T.articleSlug article)
      ,"articleTitle" .= toJSON (T.articleTitle article)
      ,"articleBody" .= toJSON (T.articleBody article)
      ,"articleAuthor" .= toJSON (T.articleAuthor article)
      ,"articleTags" .= toJSON (T.articleTags article)
    ]
