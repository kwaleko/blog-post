{-# Language OverloadedStrings #-}

module Core.Parsing where


import Data.Attoparsec.Combinator(choice
                                 ,many1
                                 ,manyTill
                                 ,lookAhead)
import Data.Attoparsec.Text(anyChar
                           ,char
                           ,endOfLine
                           ,space
                           ,string
                           ,parseOnly
                           ,Parser(..))
import Data.Text hiding(concat,map)

import qualified  Core.Types as T


runParser' :: String-> [(Text,String)]
runParser' val = case runParser (val ++ "EOA") of
  Left _ -> []
  Right content -> map (\(txt,style) -> (txt,show style)) content

runParser :: String -> Either String  [(Text,T.Style)]
runParser txt = parseOnly styling $ pack txt

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
  many1 equal
  newLine
  return [(pack title,T.Heading)]

url :: Parser [(Text,T.Style)]
url = do
  oSquareBracket
  urlName <- manyTill anyChar cSquareBracket
  oRoundBracket
  url <- manyTill anyChar cRoundBracket
  return [(pack urlName,T.URL url)]

end :: Parser [(Text,T.Style)]
end = do
  string "EOA"
  return []

code :: Parser [(Text,T.Style)]
code = do
  fourSpaces
  code <- manyTill anyChar newLine
  return [(pack code,T.Code)]

between :: Text  -> T.Style -> Parser [(Text,T.Style)]
between   parm style =   do
  string  parm
  txt <- manyTill anyChar  $ string parm
  return [(pack txt,style)]

fourSpaces :: Parser ()
fourSpaces = do
  space
  space
  space
  space
  return ()

newLine :: Parser Char
newLine = char '\n'

equal = char '='

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
