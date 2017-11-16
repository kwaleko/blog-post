{-# Language OverloadedStrings #-}
module ParseArticle where

import Data.Attoparsec.Combinator(choice,manyTill)
import Data.Attoparsec.Text(endOfLine
                           ,string
                           ,space
                           ,anyChar
                           ,char
                           ,Parser(..)
                           ,parse)
import Data.Text(pack,Text(..))

import qualified  Core.Types as T

styleParser :: Parser [(Text,T.Style)]
styleParser = choice
  [
     endP
    ,italicP
    ,headingP
    ,codeP
    ,urlP
    ,normalTextP
  ]

endP :: Parser [(Text,T.Style)]
endP = do
  endOfLine
  return [("",T.Normal)]

italicP :: Parser [(Text,T.Style)]
italicP = do
  result <- char '*' >> manyTill anyChar (char '*')
  return [(pack result,T.Italic)]

headingP :: Parser [(Text,T.Style)]
headingP = do
  result <- string (pack "**") >> manyTill anyChar (string (pack "**"))
  return [(pack result,T.Heading)]

codeP :: Parser [(Text,T.Style)]
codeP = undefined

urlP :: Parser [(Text,T.Style)]
urlP = do
  char '['
  urlName <- manyTill anyChar (char ']')
  char '('
  url <- manyTill anyChar (char ')')
  return [(pack urlName,T.URL url)]

normalTextP :: Parser [(Text,T.Style)]
normalTextP = undefined