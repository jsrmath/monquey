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
genLit (Int i) = show i
genLit (String s) = show s
genLit (Array a) = "[" ++ (intercalate ", " $ map genItem a) ++ "]"

genId :: String -> String
genId "<" = show "$lt"
genId ">" = show "$gt"
genId "<=" = show "$lte"
genId ">=" = show "$gte"
genId "=" = show "$eq"
genId "!=" = show "$ne"
genId id = show id

genPair :: Pair -> String
genPair (Pair id item) = genId id ++ ": " ++ genItem item