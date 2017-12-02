{-#Language FlexibleInstances#-}
{-#Language GeneralizedNewtypeDeriving#-}
module Effect where
import Database.HDBC.Sqlite3(Connection)
import Control.Monad.Reader
import qualified Core.Interfaces  as I
import qualified Core.Types as T
import qualified Adapter.Sqlite as S

newtype AppM a =  AppM (ReaderT Connection IO a)
  deriving (Functor,Applicative,Monad,MonadIO,MonadReader Connection)

runAppM :: Connection -> AppM a -> IO a
runAppM conn (AppM act) = runReaderT act conn

instance I.ArticleRepo AppM where
  addArticle = S.createArticle
  findArticles T.All = S.findArticles
  findArticles (T.QueryArticleBySlug slug) = S.findArticle slug
  isArticleOwnedByUser = S.isArticleOwnedByUser
  updateArticleBySlug = undefined
  deleteArticle = undefined

instance I.UserRepo AppM where
  addUser = S.register
  isEmailExists = S.isEmailExists
  isUserNameExists = S.isUserNameExists
  findUserByAuth = S.findUserByAuth
