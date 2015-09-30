{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

module Community (handleCommunity, allCommentSplices) where

import           Heist
import qualified Heist.Compiled as C
import qualified Heist.Interpreted as I
import           Data.Text (Text)
import           System.IO.Unsafe 
import           Data.Int (Int64)

import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Heist

import           Application
import           Util
---------------------------------------

data Comment = Comment {
    commentId :: Maybe Int64,
    username :: Text,
    message :: Text
} deriving Show


--this is where a database call could go
retrieveComments :: Monad n => RuntimeSplice n [Comment]
retrieveComments = return [  Comment (Just 1) "user1" "this is the first comment"
                        , Comment (Just 2) "user2" "This is the second comment"
                        ]

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



handleCommunity :: H ()
handleCommunity =
  cRender "community"
{-
  method GET  (withLoggedInUser getComments) <|>
  method POST (withLoggedInUser saveComment)
  where
    getComments user = do
      comments <- withDb $ \conn -> Db.listComments conn user
      writeJSON comments
      cRender "comments"

    saveComment user = do
      newComment <- getJSON
      either (const $ return ()) persist newComment
        where
          persist comment = do
            savedComment <- withDb $ \conn -> Db.saveComment conn user comment
            writeJSON savedComment-}
