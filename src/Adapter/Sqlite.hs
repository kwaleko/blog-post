module Adapter.Sqlite  where

import qualified Adapter.SQL as S
import qualified Core.Types  as T
import qualified Core.Parsing as P

import Control.Monad.Reader
import Database.HDBC(commit,getTables)
import Database.HDBC.Types(IConnection)
import Database.HDBC.Sqlite3(connectSqlite3,Connection(..))
import System.Directory(getHomeDirectory)
import Data.Monoid((<>))

-- create users and articles table
migrateDB :: Connection -> IO ()
migrateDB conn = do
  liftIO $ S.createTbUsers conn
  liftIO $ S.createTbArticles conn
  liftIO $ commit conn
  return ()

connect :: IO Connection
connect = do
  path <- getHomeDirectory
  let dbPath = path <> "/blog.db"
  connectSqlite3 dbPath


isEmailExists :: (MonadIO m, MonadReader r m, IConnection r ) => T.Email -> m Bool
isEmailExists email = do
  conn <- ask
  count <-liftIO $ S.countUserByEmail email conn
  case count of
    Just 1 -> return True
    _ -> return False

isUserNameExists ::(MonadIO m,MonadReader r m,IConnection r) => T.UserName -> m Bool
isUserNameExists uName = do
  conn <- ask
  count <- liftIO $ S.countUserByUser uName conn
  case count of
    Just 1 -> return True
    _ -> return False

register ::(MonadIO m,MonadReader r m,IConnection r) => T.Register -> m ()
register usr = do
  conn <- ask
  let uName = T.registerUserName usr
  let uEmail = T.registerEmail usr
  let uPass =  T.registerPassword usr
  liftIO $ S.insertUser uName uEmail uPass conn
  liftIO $ commit conn
  return ()

findUserByAuth ::(MonadIO m,MonadReader r m,IConnection r) => T.Auth -> m (Maybe T.UserId)
findUserByAuth usr = do
  conn <- ask
  let email = T.authEmail usr
  let pwd = T.authPassword usr
  liftIO $ S.getUser email pwd conn

createArticle :: (MonadIO m,MonadReader r m,IConnection r) => T.CreateArticle -> T.Slug -> T.UserId -> m ()
createArticle article slug uId = do
  conn <- ask
  let title = T.createArticleTitle article
  let body = T.createArticleBody article
  liftIO $ S.insertArticle title body slug uId conn
  liftIO $ commit conn
  return ()

findArticle ::(MonadIO m,MonadReader r m,IConnection r) => T.Slug -> m [T.Article]
findArticle slug = do
  conn <- ask
  article <- liftIO $ S.getArticle slug conn
  case article of
    Nothing ->return []
    Just (title,body,slug,uId,createdAt,updatedAt) ->
      return [
      T.Article {
           T.articleTitle = title
          ,T.articleSlug =slug
          ,T.articleBody = body
          ,T.articleAuthor = ""
          ,T.articleTags = []
          ,T.articleCreatedAt= take 10 createdAt
          ,T.articleUpdatedAt = take 10 updatedAt
          ,T.parsedArticle = P.runParser' body
                }
      ]

findArticles ::(MonadIO m,MonadReader r m,IConnection r) => m [T.Article]
findArticles = do
  conn <- ask
  articles <- liftIO $ S.getArticles conn
  case articles of
    [] -> return []
    articles -> return $ map sqlToArticle articles

isArticleOwnedByUser :: (MonadIO m,MonadReader r m,IConnection r) => T.UserId -> T.Slug -> m (Maybe Bool)
isArticleOwnedByUser uId slug = do
  conn <- ask
  count <- liftIO $ S.countArticleByUser uId slug conn
  case count of
    Just 1 -> return $ Just True
    _ -> return $ Just False


sqlToArticle :: (String,String,String,String,String,String) -> T.Article
sqlToArticle (title,body,slug,user,createdAt,updatedAt) = T.Article
  {T.articleTitle= title
  ,T.articleBody= body
  ,T.articleSlug= slug
  ,T.articleAuthor = "admin"
  ,T.articleTags= []
  ,T.articleCreatedAt = take 10 createdAt
  ,T.articleUpdatedAt = take 10 updatedAt
  ,T.parsedArticle = P.runParser' body}
