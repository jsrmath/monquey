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
	| {- empty -} { [] }

Item
	: Literal { LitItem $1 }
	| Object { ObjItem $1 }
	| EmptyObj { EmptyObj }

Object
	: Pair { [$1] }
	| Pair ',' Object { $1 : $3 }
	| ObjectId '=>' Object { [Pair $1 (ObjItem $3)] }

EmptyObj:
	'{' '}' { EmptyObj }

Array
	: '[' ']' { [] }
	| '[' ArrList ']' { $2 }

ArrList
	: Item { [$1] }
	| Item ';' ArrList { $1 : $3 }

Pair
	: ObjectId Literal { Pair $1 (LitItem $2) }
	| ObjectId Pair { Pair $1 (ObjItem [$2]) }
	| ObjectId '{' Object '}' { Pair $1 (ObjItem $3) }
	| ObjectId  EmptyObj { Pair $1 EmptyObj }

ObjectId
	: id { ObjId $1 }
 	| string { StringId $1 } 

Literal
	: string { String $1 }
	| int { Int $1 }
	| Array { Array $1 }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"

tokenChars = " |,;{}[]='\"_"

isValidId :: Char -> Bool
isValidId c = not (isInfixOf [c] tokenChars)

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
lexer ('_':cs) = lexId ('_':cs)
lexer (c:cs) 
    | isSpace c = lexer cs
    | isDigit c = lexNum (c:cs)
    | isAlpha c || isSymbol c = lexId (c:cs)
    | otherwise = parseError []

lexString cs q = TokenString str : lexer (tail rest)
   where (str, rest) = span (\c -> c /= q) cs 

lexNum cs = TokenInt (read num) : lexer rest
    where (num, rest) = span isDigit cs

lexId cs =
    case span isValidId cs of
    	(id, rest) -> TokenID id : lexer rest

main = getContents >>= putStrLn . MongoCodeGen.genCommand . mongo . lexer
}
