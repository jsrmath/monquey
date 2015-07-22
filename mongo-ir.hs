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

data Number
 	= Int Int
 	| Float Float
	deriving (Show, Read)

data Literal
	= String String
	| Bool Bool
	| Null
  	| Number Number
	| Array [Item]
	deriving Show

data Pair = Pair Key Item deriving Show

data Token = TokenID String | TokenString String | TokenNum Number | TokenPipe | TokenComma
           | TokenSemi | TokenLBrace | TokenRBrace | TokenLBracket | TokenRBracket | TokenArrow
           | TokenKeyword String
           deriving Show
