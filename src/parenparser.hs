import Text.ParserCombinators.Parsec 
import Control.Monad
import Char
import System

data Expr = Func String Expr
          | String String
          | Operator Char
          | Paren Expr
          | List [Expr]
--            deriving Show
                     
instance Show Expr where
  show (Func s (Paren e)) = capitalize s ++ "[" ++ show e ++ "]"
  show (Func s e) = s ++ "[" ++ show e ++ "]"
  show (Operator c) = c:[]
  show (String s) = s
  show (Paren e) = "(" ++ show e ++ ")"
  show (List es) = concat $ map show es
  
capitalize (s:ss) = toUpper s:map toLower ss
            
parseString :: Parser Expr
parseString = do x <- many1 (noneOf "()*+-")
                 return $ String x
                 
                 
parseOperator :: Parser Expr
parseOperator = do x <- oneOf "*+-"
                   return $ Operator x
                 
parseFunc :: Parser Expr
parseFunc = do name <- many1 letter
               args <- parseParen
               return $ Func name args
               
               
parseParen :: Parser Expr
parseParen = do char '('
                o <- parseExpr
                char ')'
                return $ Paren o
               
parseAtom :: Parser Expr
parseAtom = try parseParen <|> try parseFunc <|> try parseOperator <|> parseString

parseExpr :: Parser Expr
parseExpr = do x <- many1 parseAtom
               return $ List x

-- parseList :: Parser Expr
-- parseList = many parseExpr
              
readExpr :: String -> String
readExpr input = case parse parseExpr "lisp" input of
  Left err -> "No match: " ++ show err
  Right val -> show val


main :: IO ()
main = do args <- getArgs
          input <- readFile (args !! 0)
          putStrLn $ readExpr input
