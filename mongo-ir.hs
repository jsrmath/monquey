module MongoIR where

type Object = [Pair]
type Array = [Item]
type Identifier = String

data Command = Command [Identifier] [Item] deriving Show

data Item
	= LitItem Literal
	| ObjItem Object
	| ArrItem Array
	deriving Show

data Literal
	= String String
	| Int Int
	deriving Show

data Value
	= LitValue Literal
	| ObjValue Object
	deriving Show

data Pair = Pair Identifier Value deriving Show

data Token = TokenDB | TokenID String | TokenString String | TokenInt Int | TokenPipe | TokenComma
           | TokenSemi | TokenLBrace | TokenRBrace | TokenLBracket | TokenRBracket | TokenArrow
           deriving Show
