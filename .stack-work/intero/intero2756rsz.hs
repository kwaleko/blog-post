module Sqlite where

import qualified Adapter.SQL as S
import qualified Core.Types  as T

import Control.Monad.Reader
import Database.HDBC.Types(IConnection)
import Database.HDBC.Sqlite3(Connection(..))

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
  return ()

findArticle ::(MonadIO m,MonadReader r m,IConnection r) => T.Slug -> m [T.Article]
findArticle slug = do
  conn <- ask
  article <- liftIO $ S.getArticle slug conn
  case article of
    Just (title,body,slug,uId) -> return [ T.Article slug title body uId []]
    _ -> return []

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


sqlToArticle :: (String,String,String,String) -> T.Article
sqlToArticle = undefined
