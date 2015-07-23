module MonqueyLexer where
import Data.Char
import Data.List
import Text.Regex.Posix
import MonqueyIR

tokenChars = " |,;{}[]'\"\n"

floatRegex = "^-?([0-9]+\\.[0-9]*|[0-9]*\\.[0-9]+)"
intRegex = "^-?[0-9]+"

parseError :: [Token] -> a
parseError ts = error ("Parse error: " ++ show ts)

lexError :: Char -> a
lexError c = error ("Lexical error: " ++ show c)

isValidId :: Char -> [Char] -> Bool
isValidId '=' ('>':_) = False
isValidId c _ = not (isInfixOf [c] tokenChars)

span' :: (a -> [a] -> Bool) -> [a] -> ([a],[a])
span' _ xs@[] =  (xs, xs)
span' p xs@(x:xs')
    | p x xs'      =  let (ys,zs) = span' p xs' in (x:ys,zs)
    | otherwise    =  ([],xs)

matchNum :: String -> (String, (String -> Token)) -> Maybe (Token, [Char])
matchNum cs (regex, makeNum) = 
     let (before, n, rest) = cs =~ regex in
     if before == "" && n /= "" then Just (makeNum(n), rest)
     else Nothing

makeInt :: String -> Token
makeInt is = TokenNum (Int (read is))

makeFloat :: String -> Token
makeFloat fs = TokenNum( Float (read (zeroFill fs)))

zeroFill :: String -> String
zeroFill ('-':fs) = '-':(zeroFill fs)
zeroFill ('.':fs) = '0':'.':(zeroFill fs)
zeroFill fs = 
	case (last fs) of 
	 '.' -> fs ++ "0"
         otherwise -> fs

lexString :: [Char] -> Char -> [Token]
lexString cs q = TokenString str : lexer (tail rest)
   where (str, rest) = span (\c -> c /= q) cs 

lexNum :: [Char] -> Maybe (Token, [Char])
lexNum cs = foldr lexNum' Nothing [(intRegex, makeInt), (floatRegex, makeFloat)] where
        lexNum' x Nothing = match x
        lexNum' x res = res where
	match = matchNum cs 

lexKeyword :: [Char] -> Maybe (String, [Char])
lexKeyword cs = foldr lexKeyword' Nothing ["true", "false", "null"] where
	lexKeyword' kwd Nothing =
		let len = length kwd in
		if take len cs == kwd then Just (kwd, drop len cs) else Nothing
	lexKeyword' _ res = res

lexId :: [Char] -> [Token]
lexId cs =
    let (id, rest) = span' isValidId cs in TokenID id : lexer rest

lexer :: String -> [Token]
lexer [] = []
lexer ('|':cs) = TokenPipe : lexer cs
lexer (',':cs) = TokenComma : lexer cs
lexer (';':cs) = TokenSemi : lexer cs
lexer ('{':cs) = TokenLBrace : lexer cs
lexer ('}':cs) = TokenRBrace : lexer cs
lexer ('[':cs) = TokenLBracket : lexer cs
lexer (']':cs) = TokenRBracket : lexer cs
lexer ('=':'>':cs) = TokenArrow : lexer cs
lexer ('\'':cs) = lexString cs '\'' 
lexer ('\"':cs) = lexString cs '\"' 
lexer (c:cs) 
    | isSpace c = lexer cs
    | isDigit c || c == '-' || c == '.' = case lexNum (c:cs) of
	Just (t, rest) -> t : lexer rest
	Nothing -> parseError []
    | isValidId c cs = case lexKeyword (c:cs) of
    	Just (kwd, rest) -> TokenKeyword kwd : lexer rest
    	Nothing -> lexId (c:cs)
    | otherwise = lexError c

