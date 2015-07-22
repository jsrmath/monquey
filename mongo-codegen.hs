module MongoCodeGen where
import MongoIR
import Data.List

genCommand :: MongoIR.Command -> String
genCommand (Command ["use", id] []) = "use " ++ id ++ ";"
genCommand (Command ("db" : ids) items) =
	genBeginIds ("db" : ids) ++ "(" ++ genItems items ++ ");"
genCommand _ = "Invalid command"

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
genLit (Number (Float n)) = show n
genLit (Number (Int n)) = show n
genLit (String s) = show s
genLit (Bool True) = "true"
genLit (Bool False) = "false"
genLit Null = "null"
genLit (Array a) = "[" ++ (intercalate ", " $ map genItem a) ++ "]"

genKey :: Key -> String
genKey (IdKey "<") = show "$lt"
genKey (IdKey ">") = show "$gt"
genKey (IdKey "<=") = show "$lte"
genKey (IdKey ">=") = show "$gte"
genKey (IdKey "=") = show "$eq"
genKey (IdKey "!=") = show "$ne"
genKey (IdKey id) = show id
genKey (StringKey str) = show str

genPair :: Pair -> String
genPair (Pair key item) = genKey key ++ ": " ++ genItem item
