{
module Main where
import Data.Char
import Data.List
import Text.Regex.Posix
import MonqueyIR
import MonqueyCodeGen
import MonqueyLexer
}

%name monquey
%tokentype { Token }
%error { parseError }

%token 
	id { TokenID $$ }
	string { TokenString $$ }
	true { TokenKeyword "true" }
	false { TokenKeyword "false" }
	null { TokenKeyword "null" }
    num { TokenNum $$ }
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
	| true { Bool True }
	| false { Bool False }
	| null { Null }
	| num { Number $1 }
	| Array { Array $1 }

{
main = getContents >>= putStrLn . genCommand . monquey . lexer
}
