{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

module Community (handleCommunity, allCommentSplices) where

import           Heist
import qualified Heist.Compiled as C
import qualified Heist.Interpreted as I
import           Data.Text (Text,pack)
import           System.IO.Unsafe 
import           Data.Int (Int64)
import           Control.Applicative
import           Data.Maybe
import           Data.Aeson

import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Auth
import           Snap.Snaplet.Auth.Backends.SqliteSimple
import           Database.SQLite.Simple as S
import           Snap.Snaplet.SqliteSimple

import           Application
import           Util
import           Db
import           Login
---------------------------------------

--this is where a database call could go
retrieveComments :: Monad n => RuntimeSplice n [Comment]
retrieveComments = return []
{- Comment (Just 1) "user1" "this is the first comment"
                        , Comment (Just 2) "user2" "This is the second comment"
                        ]-}

splicesFromComment :: Monad n => Splices (RuntimeSplice n Comment -> C.Splice n)
splicesFromComment = mapS (C.pureSplice . C.textSplice) $ do
  "commentUsername"  ## username
  "commentMessage"  ## message
--  "commentPrice"   ## unsafePerformIO.tToP.ticker

renderComments :: Monad n => RuntimeSplice n [Comment] -> C.Splice n
renderComments = C.manyWithSplices C.runChildren splicesFromComment

allCommentSplices :: Monad n => Splices (C.Splice n)
allCommentSplices =
  "allComments" ## (renderComments retrieveComments)


-------------------------------------------------------------------------------
-- | Run an IO action with a SQLite connection

withDb :: (S.Connection -> IO a) -> H a
withDb action =
  withTop db . withSqlite $ \conn -> action conn

handleCommunity :: H ()
handleCommunity =
  --method GET  (withLoggedInUser getComments) <|>
  method POST (withLoggedInUser postComment) <|>
  allC 
  where
    allC = do
      comments <- withDb $ \conn -> listComments conn
      writeJSON comments
      cRender "community"
 
    postComment user = do
      newComment <- getJSON
      r <- getPostParams
      either (return $ writeText $ pack $ show r) persist newComment
      allC
        where
          persist comment = do
            savedComment <- withDb $ \conn -> saveComment conn user comment
            writeJSON savedComment
