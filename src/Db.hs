{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Db (
    User(..)
  , Comment(..)
  , createTables
  , listComments
  , saveComment
  ) where

import           Control.Applicative
import           Control.Monad
import           Data.Aeson
import           Data.Int (Int64)
import           Data.Maybe
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Database.SQLite.Simple
import           Database.SQLite.Simple.ToField

import           Snap.Core
import           Snap.Snaplet.Auth
import           Snap.Snaplet.Auth.Backends.SqliteSimple

data User = User Int Text
--maybe have a stock database entry version?
--this version includes all the right data/formats
--data CommentDBE = CommentDBE Maybe Int64 Comment


data Comment = Comment {
    commentId :: Maybe Int64,
    user_id :: Text,
    date :: Text,
    username :: Text,
    message :: Text
} deriving Show 

instance ToField Comment where
  

instance FromJSON Comment where
  parseJSON (Object v) =
    Comment <$> optional (v .: "id")
            <*> v .: "user_id"
            <*> v .: "date"
            <*> v .: "username"
            <*> v .: "message"
  parseJSON _ = mzero

instance ToJSON Comment where
  toJSON (Comment i uid date message username) =
    object [ "id" .= fromJust i
           , "user_id" .= uid
           , "date" .= date
           , "message" .= message
           , "username" .= username
           ]

instance FromRow Comment where
  fromRow = Comment <$> field <*> field <*> field <*> field <*> field


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
  schemaCreated <- tableExists conn "comments"
  unless schemaCreated $
    execute_ conn
      (Query $
       T.concat [ "CREATE TABLE comments ("
                , "id INTEGER PRIMARY KEY, "
                , "user_id TEXT NOT NULL, "
                , "saved_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, "
                , "message TEXT, "
                , "username TEXT)"])

-----------------------------------------------------------
-- | Retrieve list of all comments
--   make these polymorphic?
listComments :: Connection -> IO [Comment]
listComments conn =
  query conn "SELECT * FROM comments" ()

-- | Save or update a stock
saveComment :: Connection -> User -> Comment -> IO Comment
saveComment conn (User uid _) t =
  maybe newComment updateComment (commentId t)
  where
    newComment = do
      execute conn "INSERT INTO comments (user_id,message,username) VALUES (?,?,?)" (uid, message t,username t)
      rowId <- lastInsertRowId conn
      return $ t { commentId = Just rowId }

    updateComment tid = undefined
    --do
    {-  execute conn "UPDATE stocks SET number = ?, ticker = ? WHERE (user_id = ? AND id = ?)"
        (number t, ticker t, uid, tid)
      return t-}

