{
module Main where
import Data.Char
import MongoIR
import MongoCodeGen
}

%name mongo
%tokentype { Token }
%error { parseError }

%token 
	db { TokenDB }
	id { TokenID $$ }
	string { TokenString $$ }
	int { TokenInt $$ }
	'|' { TokenPipe }
	',' { TokenComma }
	';' { TokenSemi }
	'{' { TokenLBrace }
	'}' { TokenRBrace }
	'[' { TokenLBracket }
	']' { TokenRBracket }
	'=>' { TokenArrow }

%%

Command : db id id Arglist { Command $2 $3 $4 }

Arglist
	: '|' Item Arglist { $2 : $3 }
	| {- empty -} { [] }

Item
	: Literal { LitItem $1 }
	| Object { ObjItem $1 }

Object
	: Pair { [$1] }
	| Pair ',' Object { $1 : $3 }
	| id '=>' Object { [Pair $1 (ObjValue $3)] }

Array
	: '[' ']' { [] }
	| '[' ArrList ']' { $2 }

ArrList
	: Item { [$1] }
	| Item ';' ArrList { $1 : $3 }

Pair
	: id Literal { Pair $1 (LitValue $2) }
	| id Pair { Pair $1 (ObjValue [$2]) }
	| id '{' Object '}' { Pair $1 (ObjValue $3) }

Literal
	: string { String $1 }
	| int { Int $1 }
	| Array { Array $1 }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"

lexer :: String -> [Token]
lexer [] = []
lexer (c:cs) 
    | isSpace c = lexer cs
    | isAlpha c = lexId (c:cs)
    | isDigit c = lexNum (c:cs)
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

lexString cs q = TokenString str : lexer (tail rest)
   where (str, rest) = span (\c -> c /= q) cs 

lexNum cs = TokenInt (read num) : lexer rest
    where (num,rest) = span isDigit cs

lexId cs =
    case span isAlpha cs of
    	("db",rest) -> TokenDB : lexer rest
    	(id,rest) -> TokenID id : lexer rest

main = getContents >>= putStrLn . MongoCodeGen.genCommand . mongo . lexer
}