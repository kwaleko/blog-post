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
                           ,many1
                           ,Parser(..)
                           ,parse
                           ,parseOnly
                           ,feed)
import Data.Text.Internal
import Data.Text hiding(concat)

import qualified  Core.Types as T

-- parser for article styling --

styling :: Parser [(Text,T.Style)]
styling  = concat <$> manyTill (choice [styledTxt,unstyledTxt])  end
styledTxt :: Parser [(Text,T.Style)]
styledTxt = choice[code
                  ,heading
                  ,bold
                  ,italic
                  ,mark
                  ,url
                  ,end]

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
  newLine
  title <- manyTill anyChar newLine
  manyTill spaceOrEqual newLine
  return [(pack title,T.Heading)]

url :: Parser [(Text,T.Style)]
url = do
  oSquareBracket
  urlName <- manyTill anyChar cSquareBracket
  oRoundBracket
  url <- manyTill anyChar cRoundBracket
  return [(pack urlName,T.URL url)]

end :: Parser [(Text,T.Style)]
end = string "EOA" >> return []

code :: Parser [(Text,T.Style)]
code = do
  fourSpaces
  code <- manyTill anyChar newLine
  newLine
  return [(pack code,T.Code)]

between :: Text -> T.Style -> Parser [(Text,T.Style)]
between   parm style =  undefined -- do
 -- string  parm
 -- txt <- manyTill anyChar  $ string parm
 -- return [(pack txt,style)]

fourSpaces :: Parser ()
fourSpaces = do
  space
  space
  space
  space
  return ()

newLine :: Parser Char
newLine = char '\n'

spaceOrEqual :: Parser Char
spaceOrEqual = choice [char '=',space]

oSquareBracket :: Parser Char
oSquareBracket = char '['

oRoundBracket :: Parser Char
oRoundBracket = char '('

cRoundBracket :: Parser Char
cRoundBracket = char ')'

cSquareBracket :: Parser Char
cSquareBracket = char ']'
