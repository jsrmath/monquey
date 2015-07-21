{
module Main where
import Data.Char
import Data.List
import MongoIR
import MongoCodeGen
}

%name mongo
%tokentype { Token }
%error { parseError }

%token 
	id { TokenID $$ }
	string { TokenString $$ }
	int { TokenInt $$ }
	true { TokenKeyword "true" }
	false { TokenKeyword "false" }
	null { TokenKeyword "null" }
	'|' { TokenPipe }
	',' { TokenComma }
	';' { TokenSemi }
	'{' { TokenLBrace }
	'}' { TokenRBrace }
	'[' { TokenLBracket }
	']' { TokenRBracket }
	'=>' { TokenArrow }

%%

Command : Idlist Arglist { Command $1 $2 }

Idlist
	: id { [$1] }
	| id Idlist { $1 : $2}

Arglist
	: '|' Item Arglist { $2 : $3 }
	| '|' Arglist { EmptyObj : $2 }
	| {- empty -} { [] }

Item
	: Literal { LitItem $1 }
	| Object { ObjItem $1 }
	| EmptyObj { EmptyObj }

Object
	: Pair { [$1] }
	| Pair ',' Object { $1 : $3 }
	| Key '=>' Object { [Pair $1 (ObjItem $3)] }

EmptyObj:
	'{' '}' { EmptyObj }

Array
	: '[' ']' { [] }
	| '[' ArrList ']' { $2 }

ArrList
	: Item { [$1] }
	| Item ';' ArrList { $1 : $3 }

Pair
	: Key Literal { Pair $1 (LitItem $2) }
	| Key Pair { Pair $1 (ObjItem [$2]) }
	| Key '{' Object '}' { Pair $1 (ObjItem $3) }
	| Key EmptyObj { Pair $1 EmptyObj }

Key	
	: id { IdKey $1 }
 	| string { StringKey $1 } 

Literal
	: string { String $1 }
	| int { Int $1 }
	| true { Bool True }
	| false { Bool False }
	| null { Null }
	| Array { Array $1 }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"

tokenChars = " |,;{}[]'\"\n"

isValidId :: Char -> [Char] -> Bool
isValidId '=' ('>':_) = False
isValidId c _ = not (isInfixOf [c] tokenChars)

span' :: (a -> [a] -> Bool) -> [a] -> ([a],[a])
span' _ xs@[] =  (xs, xs)
span' p xs@(x:xs')
    | p x xs'      =  let (ys,zs) = span' p xs' in (x:ys,zs)
    | otherwise    =  ([],xs)

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
    | isDigit c = lexNum (c:cs)
    | isValidId c cs = case lexKeyword (c:cs) of
    	Just (kwd, rest) -> TokenKeyword kwd : lexer rest
    	Nothing -> lexId (c:cs)
    | otherwise = parseError []

lexString cs q = TokenString str : lexer (tail rest)
   where (str, rest) = span (\c -> c /= q) cs 

lexNum cs = TokenInt (read num) : lexer rest
    where (num, rest) = span isDigit cs

lexKeyword :: [Char] -> Maybe (String, [Char])
lexKeyword cs = foldr lexKeyword' Nothing ["true", "false", "null"] where
	lexKeyword' kwd Nothing =
		let len = length kwd in
		if take len cs == kwd then Just (kwd, drop len cs) else Nothing
	lexKeyword' _ res = res

lexId cs =
    let (id, rest) = span' isValidId cs in TokenID id : lexer rest

main = getContents >>= putStrLn . MongoCodeGen.genCommand . mongo . lexer
}
