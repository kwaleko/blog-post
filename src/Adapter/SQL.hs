{-#LANGUAGE QuasiQuotes #-}
module Adapter.SQL (countUserByEmail
                     ,countUserByUser
                     ,createTbArticles
                     ,createTbUsers
                     ,getUser
                     ,insertUser
                     --Articles
                     ,insertArticle
                     ,countArticleByUser
                     ,getArticle
                     ,getArticles
                     ,deleteArticle
                     ) where


import            Database.YeshQL
import            Database.HDBC(commit,run,toSql,disconnect )
--import            Database.HDBC.Sqlite3(connectSqlite3,Connection)

import qualified Core.Types as T



--  SQL queries to maipulate users --
[yesh|
     -- name:createTbArticles::rowcount Int
     CREATE TABLE IF NOT EXISTS articles (
      recid  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE
     ,title TEXT NOT NULL
     ,body TEXT NOT NULL
     ,slug TEXT
     ,userid INTEGER
     ,tags TEXT
     ,createdat TEXT DEFAULT CURRENT_TIMESTAMP
     ,modifiedat TEXT DEFAULT CURRENT_TIMESTAMP )
     ;;;
     -- name:createTbUsers :: rowcount Int
     CREATE TABLE IF NOT EXISTS users (
      userid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE
     ,username TEXT UNIQUE
     ,email TEXT UNIQUE
     ,password TEXT )
|]
[yesh|
  -- name:countUserByEmail :: (Int)
  -- :email :: String
  SELECT COUNT(userid) FROM users WHERE email = :email
  ;;;
  -- name:countUserByUser ::(Int)
  -- :userName :: String
  SELECT COUNT(userid) FROM users where username = :userName
  ;;;
  -- name:getUser ::(Int)
  -- :email :: String
  -- :pass :: String
  SELECT userid FROM users where email = :email AND password = :pass
  ;;;
   -- name:insertUser :: rowcount Int
   -- :userName :: String
   -- :email :: String
   -- :pwd :: String
   Insert INTO users (username,email,password) VALUES (:userName,:email,:pwd)
|]

--  SQL queries to manipulate articles --
[yesh|
     --name:insertArticle :: rowcount Int
     -- :title :: String
     -- :body :: String
     -- :slug :: String
     -- :userid :: Int
     INSERT INTO articles (title,body,slug,userid) VALUES (:title,:body,:slug,:userid)
     ;;;
     -- name:updateArticle :: rowcount Int
     -- :slug :: String
     -- :title :: String
     -- :body :: String
     UPDATE ARTICLES SET title = :title , body = :body WHERE slug = :slug
     ;;;
     --name:countArticleByUser :: (Int)
     -- :userId :: Int
     -- :slug :: String
     SELECT COUNT(recid) FROM articles WHERE recid= :userId and slug= :slug
     ;;;
     --name:getArticles :: [(String,String,String,String,String,String)]
     SELECT title,body,slug,userid,createdat,modifiedat,tags FROM articles
     ;;;
     --name:getArticle :: (String,String,String,String,String,String)
     -- :slug :: String
     SELECT title,body,slug,userid,createdat,modifiedat FROM articles WHERE slug = :slug
     ;;;
     --name:deleteArticle :: rowcount Int
     -- :slug :: String
     DELETE FROM articles WHERE slug= :slug
     ;;;
     --name:deleteArticles :: rowcount Int
     DELETE FROM articles
|]

{- insert  = do
  conn <- connect1
  migrateDB conn
  commit conn
  disconnect conn -}
