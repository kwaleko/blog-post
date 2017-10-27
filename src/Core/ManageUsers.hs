module ManageUsers where

import Control.Monad.Except

import qualified Core.Types as T

register :: (T.UserRepo m) => T.Register -> ExceptT T.UserError m T.UserId
register user = do
  let uName =  T.registerUserName user
  let uEmail = T.registerEmail user
  let uPass = T.registerPassword user
  userNameFound <- lift $ T.isUserNameExists  uName
  emailFound <- lift $ T.isEmailExists uEmail
  checkUserDataForRegister (uName,userNameFound) (uEmail,emailFound)
  T.register user
  login $ T.Auth uEmail uPass

checkUserDataForRegister :: (T.UserRepo m) => (T.UserName,Bool) -> (T.Email,Bool) -> ExceptT T.UserError m ()
checkUserDataForRegister (uName,nFound) (uEmail,eFound)  | nFound = throwError $ T.RegisterErrorUserNameTaken uName
                                                         | eFound = throwError $ T.RegisterErrorEmailTaken uEmail
                                                         | not  (nFound && eFound)  = return ()

login :: (T.UserRepo m) => T.Auth -> ExceptT T.UserError m T.UserId
login auth = do
  result <- lift $ T.findUserByAuth auth
  case result of
    Nothing -> throwError T.AuthErrorBadAuthentication
    (Just userid) -> return userid
