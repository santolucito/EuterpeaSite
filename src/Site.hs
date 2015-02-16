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

import           Application
import           Stock
import qualified Db
import           Util
------------------------------------------------------------------------------

type H = Handler App App

-- | Render login form
handleLogin :: Maybe T.Text -> Handler App (AuthManager App) ()
handleLogin authError = heistLocal (I.bindSplices errs) $ render "login"
  where
    errs = maybe noSplices splice authError
    splice err = "loginError" ## I.textSplice err


------------------------------------------------------------------------------
-- | Handle login submit
handleLoginSubmit :: H ()
handleLoginSubmit =
  with auth $ loginUser "login" "password" Nothing
    (\_ -> handleLogin . Just $ "Unknown login or incorrect password")
    (redirect "/stocks")

------------------------------------------------------------------------------
-- | Logs out and redirects the user to the site index.
handleLogout :: H ()
handleLogout = with auth logout >> redirect "/"

------------------------------------------------------------------------------
-- | Handle new user form submit

handleNewUser :: H ()
handleNewUser =
  method GET (renderNewUserForm Nothing) <|> method POST handleFormSubmit
  where
    handleFormSubmit = do
      authUser <- with auth $ registerUser "login" "password"
      either (renderNewUserForm . Just) login authUser

    renderNewUserForm (err :: Maybe AuthFailure) =
      heistLocal (I.bindSplices errs) $ render "new_user"
      where
        errs = maybe noSplices splice err
        splice e = "newUserError" ## I.textSplice . T.pack . show $ e

    login user =
      logRunEitherT $
        lift (with auth (forceLogin user) >> redirect "/")

-----------------------------------------------------------------------------
-- | Run actions with a logged in user or go back to the login screen
withLoggedInUser :: (Db.User -> H ()) -> H ()
withLoggedInUser action =
  with auth currentUser >>= go
  where
    go Nothing  =
      with auth $ handleLogin (Just "Must be logged in to view the main page")
    go (Just u) = logRunEitherT $ do
      uid  <- tryJust "withLoggedInUser: missing uid" (userId u)
      uid' <- hoistEither (reader T.decimal (unUid uid))
      return $ action (Db.User uid' (userLogin u))

-------------------------------------------------------------------------------
-- | Run an IO action with an SQLite connection
withDb :: (S.Connection -> IO a) -> H a
withDb action =
  withTop db . withSqlite $ \conn -> action conn

handleStocks :: H ()
handleStocks =
  method GET  (withLoggedInUser getStocks) <|>
  method POST (withLoggedInUser saveStock)
  where
    getStocks user = do
      stocks <- withDb $ \conn -> Db.listStocks conn user
      writeJSON stocks
      cRender "stocks"

    saveStock user = do
      newStock <- getJSON
      either (const $ return ()) persist newStock
        where
          persist stock = do
            savedStock <- withDb $ \conn -> Db.saveStock conn user stock
            writeJSON savedStock


------------------------------------------------------------------------------
-- | Handle stocks
handleStock :: H ()
handleStock =  cRender "stocks"

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
         , ("",            cRender "post")
         ]


------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "app" "A snaplet example application." Nothing $ do
    h <- nestSnaplet "" heist $ heistInit "templates"
    addRoutes routes
    addConfig h (mempty & scCompiledSplices .~  allStockSplices)

    s <- nestSnaplet "sess" sess $
           initCookieSessionManager "site_key.txt" "sess" (Just 3600)

    d <- nestSnaplet "db" db sqliteInit
    a <- nestSnaplet "auth" auth $ initSqliteAuth sess d

    -- Grab the DB connection pool from the sqlite snaplet and call
    -- into the Model to create all the DB tables if necessary.
    let conn = sqliteConn $ d ^# snapletValue
    liftIO $ withMVar conn $ Db.createTables

    addAuthSplices h auth
    return $ App h s d a
