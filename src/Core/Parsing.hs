{-# Language OverloadedStrings #-}
module Parsing where


import Data.Attoparsec.Combinator(choice
                                 ,manyTill
                                 ,lookAhead)
import Data.Attoparsec.Text(endOfLine
                           ,try
                           ,string
                           ,space
                           ,anyChar
                           ,char
                           ,space
                           ,notChar
                           ,skipSpace
                           ,skipWhile
                           ,satisfy
                           ,Parser(..)
                           ,parse)
import Data.Text(pack,Text(..))

import qualified  Core.Types as T

-- parser for article styling --

styling :: Parser [(Text,T.Style)]
styling  = concat <$> manyTill (choice [styledTxt,unstyledTxt]) endOfLine

styledTxt :: Parser [(Text,T.Style)]
styledTxt = choice[end
                  ,code
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
heading = do
  char '\n'
  title <- manyTill anyChar $ char '\n'
  manyTill (choice [char '=',space]) (char '\n')
  return [(pack title,T.Heading)]

url :: Parser [(Text,T.Style)]
url = do
  char '['
  urlName <- manyTill anyChar $ char ']'
  char '('
  url <- manyTill anyChar $ char ')'
  return [(pack urlName,T.URL url)]

end :: Parser [(Text,T.Style)]
end = endOfLine >> return []

code :: Parser [(Text,T.Style)]
code = do
  fourSpaces
  txt <- manyTill anyChar $ char '\n'
  return [(pack txt,T.Code)]

between :: Text -> T.Style -> Parser [(Text,T.Style)]
between  parm style = do
  result <- string parm >> manyTill anyChar (string parm)
  return [(pack result,style)]

fourSpaces :: Parser ()
fourSpaces = undefined

  -- parse to generate slug --

slugify :: Parser [Text]
slugify = manyTill (choice[skipSpaces,tillSpace]) end

tillSpace :: Parser Text
tillSpace = do
  str <- manyTill anyChar $ choice[endOfLine >> return [],space >> return []]
  return $ pack str

skipSpaces :: Parser Text
skipSpaces = do
  manyTill space $ choice[endOfLine >> return [],lookAhead notSpace >> return []]
  return $ pack []

notSpace :: Parser Char
notSpace = satisfy ( /= ' ')
