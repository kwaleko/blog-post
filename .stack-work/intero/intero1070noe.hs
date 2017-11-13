{-# Language OverloadedStrings #-}
module ParseArticle where

import Data.Char (isSpace)
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

articleP :: Parser [(Text,T.Style)]
articleP = concat <$> manyTill styleParser endOfLine

styleParser :: Parser [(Text,T.Style)]
styleParser = choice
  [
     boldP
    ,italicP
    ,markP
    ,urlP
    ,anyP
  ]

styleParser' :: Parser [(Text,T.Style)]
styleParser' = choice
  [
     boldP
    ,italicP
    ,markP
    ,urlP
    ,anyP
  ]

anyP :: Parser [(Text,T.Style)]
anyP = do
  caracter <- anyChar
  return [(pack [caracter],T.Normal)]

anyP' :: Parser [(Text,T.Style)]
anyP' = return [ (pack ()manyTill anyChar $ lookAhead styleParser'),T.Normal)]

inBetweenP :: T.Style -> Parser a -> Parser [(Text,T.Style)]
inBetweenP style parser = do
  result <- parser >> manyTill anyChar parser
  return [(pack result,style)]

boldP :: Parser [(Text,T.Style)]
boldP = inBetweenP T.Bold $ string $ pack "**"

italicP :: Parser [(Text,T.Style)]
italicP = inBetweenP  T.Italic (char '*')

markP :: Parser [(Text,T.Style)]
markP = inBetweenP T.Mark $ string $ pack "##"

headingP :: Parser [(Text,T.Style)]
headingP =  undefined

urlP :: Parser [(Text,T.Style)]
urlP = do
  char '['
  urlName <- manyTill anyChar (char ']')
  char '('
  url <- manyTill anyChar (char ')')
  return [(pack urlName,T.URL url)]
