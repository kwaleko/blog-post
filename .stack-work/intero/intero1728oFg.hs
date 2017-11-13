{-# Language OverloadedStrings #-}
module ParseArticle where

import Data.Char (isSpace,length)
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
styledTxt = choice
  [
    endOfLine>> return []
     ,boldP
    ,italicP
    ,markP
    ,urlP
    --,anyP
  ]

unstyledTxt :: Parser [(Text,T.Style)]
unstyledTxt = do
  result <- manyTill anyChar $ lookAhead styledTxt
  return [(pack result,T.Normal)]

between :: a -> T.Style -> Parser [(Text,T.Style)]
between style parm = do
  result <- (case length parm of
    1 -> char parm >> manyTill anyChar $ char parm
    _ -> string parm >> manyTill anyChar $ string parm)
  return [(pack result,style)]

bold :: Parser [(Text,T.Style)]
bold = between "**" T.Bold

italic :: Parser [(Text,T.Style)]
italic = between '*' T.Italic

mark :: Parser [(Text,T.Style)]
mark = between "##" T.Mark

heading :: Parser [(Text,T.Style)]
heading =  undefined

urlP :: Parser [(Text,T.Style)]
urlP = do
  char '['
  urlName <- manyTill anyChar (char ']')
  char '('
  url <- manyTill anyChar (char ')')
  return [(pack urlName,T.URL url)]
