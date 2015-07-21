module MongoIR where

type Object = [Pair]
type Identifier = String

data Command = Command [Identifier] [Item] deriving Show

data Item
	= LitItem Literal
	| ObjItem Object
	| EmptyObj
	deriving Show

data Key 
	= IdKey Identifier  
    | StringKey String
	deriving Show

data Literal
	= String String
	| Int Int
	| Array [Item]
	deriving Show

data Pair = Pair Key Item deriving Show

data Token = TokenDB | TokenID String | TokenString String | TokenInt Int | TokenPipe | TokenComma
           | TokenSemi | TokenLBrace | TokenRBrace | TokenLBracket | TokenRBracket | TokenArrow
           deriving Show
