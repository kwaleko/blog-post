{-# Language OverloadedStrings #-}
module ParseArticle where


import Data.Attoparsec.Combinator(choice,manyTill,lookAhead)
import Data.Attoparsec.Text(endOfLine
                           ,try
                           ,string
                           ,space
                           ,anyChar
                           ,char
                           ,Parser(..)
                           ,parse)
import Data.Text(pack,Text(..))

import qualified  Core.Types as T

styling :: Parser [(Text,T.Style)]
styling  = concat <$> manyTill (choice [styledTxt,unstyledTxt]) endOfLine

styledTxt :: Parser [(Text,T.Style)]
styledTxt = choice[end
                  ,heading
                  ,bold
                  ,italic
                  ,mark
                  ,url]

unstyledTxt :: Parser [(Text,T.Style)]
unstyledTxt = do
  result <- manyTill anyChar $ lookAhead styledTxt
  return [(pack result,T.Normal)]

bold :: Parser [(Text,T.Style)]
bold = between "**" T.Bold

italic :: Parser [(Text,T.Style)]
italic = between "*" T.Italic

mark :: Parser [(Text,T.Style)]
mark = between "##" T.Mark

heading :: Parser [(Text,T.Style)]
heading =  undefined

url :: Parser [(Text,T.Style)]
url = do
  char '['
  urlName <- manyTill anyChar (char ']')
  char '('
  url <- manyTill anyChar (char ')')
  return [(pack urlName,T.URL url)]

end :: Parser [(Text,T.Style)]
end = endOfLine >> return []

between :: Text -> T.Style -> Parser [(Text,T.Style)]
between  parm style = do
  result <- string parm >> manyTill anyChar (string parm)
  return [(pack result,style)]
