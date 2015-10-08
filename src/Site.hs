{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site
  ( app
  ) where

------------------------------------------------------------------------------
import           Control.Applicative
import           Control.Lens ((^#))
import           Control.Concurrent (withMVar)
import           Control.Monad.Trans (liftIO, lift)
import           Control.Monad.Trans.Either
import           Control.Error.Safe (tryJust)
import           Lens.Family                ((&), (.~))
import           Data.ByteString as B
import qualified Data.Text as T
import qualified Data.Text.Read as T
import           Data.Monoid
------------------------------------------------------------------------------

import           Database.SQLite.Simple as S
import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Auth
import           Snap.Snaplet.Auth.Backends.SqliteSimple
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Session.Backends.CookieSession
import           Snap.Snaplet.SqliteSimple
import           Snap.Util.FileServe
import           Heist
import qualified Heist.Interpreted as I
------------------------------------------------------------------------------

import           Community
import           Application
import           Stock
import qualified Db
import           Util
import           Login

------------------------------------------------------------------------------
-- | Handle posts
handlePost :: H ()
handlePost = do
--  infoLog ["handler" <=> "postHandler"]
  (Just c) <- getParam "cat"
  (Just k) <- getParam "key"
  --cRender $ B.append (B.intercalate "/" ["posts", c, k]) ".md"
  cRender $ (B.intercalate "/" ["posts", c,k])

------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(B.ByteString, Handler App App ())]
routes = [ ("/about",      cRender "about")
         , ("/install",    cRender "install")
         , ("/posts/",     cRender "post")
         , ("/posts/:cat", cRender "post")
         , ("/posts/:cat/:key", handlePost)
         , ("/new_user", handleNewUser)
         , ("/login",    handleLoginSubmit)
         , ("/logout",   handleLogout)
         , ("/community",   handleCommunity)
         , ("",            serveDirectory "static")
         ]


------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "app" "A snaplet example application." Nothing initProcess


initProcess :: Initializer App App App
initProcess = do
    h <- nestSnaplet "" heist $ heistInit "templates"
    addRoutes routes
    addConfig h (mempty & scCompiledSplices .~  allCommentSplices)

    s <- nestSnaplet "sess" sess $
           initCookieSessionManager "site_key.txt" "sess" (Just 3600)

    d <- nestSnaplet "db" db sqliteInit
    a <- nestSnaplet "auth" auth $ initSqliteAuth sess d

    -- Grab the DB connection pool from the sqlite snaplet and call
    -- into the Model to create all the DB tables if necessary.
    let conn = sqliteConn $ d ^# snapletValue
    liftIO $ withMVar conn $ Db.createTables

    addAuthSplices h auth
    wrapSite (\site -> site <|> cRender "404")
    return $ App h s d a
