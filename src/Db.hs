{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

module Db (
    User(..)
  , createTables
  , saveStock
  , listStocks) where

import           Control.Applicative
import           Control.Monad
import           Data.Aeson
import           Data.Int (Int64)
import           Data.Maybe
import           Data.Text (Text)
import qualified Data.Text as T
import           Database.SQLite.Simple
import           Stock

data User = User Int Text
--maybe have a stock database entry version?
--this version includes all the right data/formats
--data StockDBE = StockDBE Maybe Int64 Stock


instance FromJSON Stock where
  parseJSON (Object v) =
    Stock <$> optional (v .: "id")
          <*> v .: "number"
          <*> v .: "ticker"
  parseJSON _ = mzero

instance ToJSON Stock where
  toJSON (Stock i number ticker) =
    object [ "id" .= fromJust i
           , "number" .= number
           , "ticker" .= ticker
           ]

instance FromRow Stock where
  fromRow = Stock <$> field <*> field <*> field

tableExists :: Connection -> String -> IO Bool
tableExists conn tblName = do
  r <- query conn "SELECT name FROM sqlite_master WHERE type='table' AND name=?" (Only tblName)
  case r of
    [Only (_ :: String)] -> return True
    _ -> return False

-- | Create the necessary database tables, if not already initialized.
createTables :: Connection -> IO ()
createTables conn = do
  -- Note: for a bigger app, you probably want to create a 'version'
  -- table too and use it to keep track of schema version and
  -- implement your schema upgrade procedure here.
  schemaCreated <- tableExists conn "stocks"
  unless schemaCreated $
    execute_ conn
      (Query $
       T.concat [ "CREATE TABLE stocks ("
                , "id INTEGER PRIMARY KEY, "
                , "user_id INTEGER NOT NULL, "
                , "saved_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, "
                , "number TEXT, "--TODO change to INTEGER NOT NULL
                , "ticker TEXT)"])

-- | Retrieve a user's list of comments
listStocks :: Connection -> User -> IO [Stock]
listStocks conn (User uid _) =
  query conn "SELECT id,number,ticker FROM stocks WHERE user_id = ?" (Only uid)

-- | Save or update a stock
saveStock :: Connection -> User -> Stock -> IO Stock
saveStock conn (User uid _) t =
  maybe newStock updateStock (stockId t)
  where
    newStock = do
      execute conn "INSERT INTO stocks (user_id,number,ticker) VALUES (?,?,?)"
        (uid, number t, ticker t)
      rowId <- lastInsertRowId conn
      return $ t { stockId = Just rowId }

    updateStock tid = do
      execute conn "UPDATE stocks SET number = ?, ticker = ? WHERE (user_id = ? AND id = ?)"
        (number t, ticker t, uid, tid)
      return t
