{-# Language OverloadedStrings #-}
module ParseArticle where

import Data.Attoparsec.Text(endOfLine
                           ,string
                           ,space
                           ,anyChar
                           ,(<|>)
                           ,Parser(..))
import Data.Text(pack,Text(..))

import qualified  Core.Types as T

styleParser :: Parser [(Text,T.Style)]
styleParser = undefined

end :: Parser [()]
end = undefined
