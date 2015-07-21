module MongoCodeGen where
import MongoIR
import Data.List

genCommand :: MongoIR.Command -> String
genCommand (Command ids items) =
	genBeginIds ids ++ "(" ++ genItems items ++ ");" 

genBeginIds :: [Identifier] -> String
genBeginIds ids = intercalate "." ids

genItems :: [Item] -> String
genItems items = intercalate ", " $ map genItem items

genItem :: Item -> String
genItem (LitItem lit) = genLit lit
genItem (ObjItem obj) = genObj obj
genItem EmptyObj = "{}"

genObj :: Object -> String
genObj obj = "{" ++ (intercalate ", " $ map genPair obj) ++ "}"

genLit :: Literal -> String
genLit (Int i) = show i
genLit (String s) = "\"" ++ s ++ "\""
genLit (Array a) = "[" ++ (intercalate ", " $ map genItem a) ++ "]"

genKey :: Key -> String
genKey (IdKey id) = "\"" ++ id ++ "\""
genKey (StringKey s) = "\"" ++ s ++ "\""

genPair :: Pair -> String
genPair (Pair key item) = genKey key ++ ": " ++ genItem item
