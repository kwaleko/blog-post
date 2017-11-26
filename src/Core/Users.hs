module Core.Users where

import Control.Monad.Except
import qualified Core.Types as T
import qualified Core.Interfaces as I

register :: (I.UserRepo m) => T.Register -> ExceptT T.UserError m T.UserId
register user = do
  let uName =  T.registerUserName user
  let uEmail = T.registerEmail user
  let uPass = T.registerPassword user
  userNameFound <- lift $ I.isUserNameExists  uName
  emailFound <- lift $ I.isEmailExists uEmail
  checkUserDataForRegister (uName,userNameFound) (uEmail,emailFound)
  lift $  I.addUser user
  login $ T.Auth uEmail uPass

checkUserDataForRegister :: (I.UserRepo m) => (T.UserName,Bool) -> (T.Email,Bool) -> ExceptT T.UserError m ()
checkUserDataForRegister (uName,nFound) (uEmail,eFound)  | nFound = throwError $ T.RegisterErrorUserNameTaken uName
                                                         | eFound = throwError $ T.RegisterErrorEmailTaken uEmail
                                                         | not  (nFound && eFound)  = return ()

login :: (I.UserRepo m) => T.Auth -> ExceptT T.UserError m T.UserId
login auth = do
  result <- lift $ I.findUserByAuth auth
  case result of
    Nothing -> throwError T.AuthErrorBadAuthentication
    (Just userid) -> return userid
