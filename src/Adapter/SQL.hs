{-#LANGUAGE QuasiQuotes #-}
module DatabaseUtils (addUser
                     ,findUser
                     ,isEmailExists
                     ,isUserNameExists
                     ) where


import            Database.YeshQL

import qualified Core.Types as T

[yesh|
  -- name:isEmailExists :: (Bool)
  -- :email :: String
  SELECT true FROM users WHERE email = :email
|]

[yesh|
     -- name:isUserNameExists ::(Bool)
     -- :userName :: String
     SELECT true FROM users where username = :userName
|]

[yesh|
     -- name:findUser ::(Int)
     -- :email :: String
     -- :pass :: String
     SELECT userid FROM users where email = :email AND password = :pass
|]

[yesh|
     --name:addUser :: (Int)
     -- :userName :: String
     -- :email :: String
     -- :pwd :: String
     INSERT INTO user VALUES (:userName,:email,:pwd)
|]
