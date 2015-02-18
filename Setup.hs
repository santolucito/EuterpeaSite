{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
import Shelly
import Control.Monad
import Data.List
import qualified Data.Text as T
default (T.Text)

main = do
  f <- shelly preBuild
  print f

preBuild  = do
  dir   <- pwd
  --build all posts from lhs
  let p = (dir </> "snaplets" </> "heist" </> "templates" </> "posts")
  files <- findWhen isHaskell p
  forM files convert_lhs_to_tpl

  --build index page
  let i = (dir </> "snaplets" </> "heist" </> "templates")
  indx <- findWhen isIndex i
  writeIndexTpl (head indx) files
  return ()

writeIndexTpl :: Shelly.FilePath -> [Shelly.FilePath] -> Sh ()
writeIndexTpl i files =
  let
    fileWoExt f =  (T.reverse . T.drop 4 . T.reverse) f
    shorten y =
      T.concat $ intersperse "/" (drop 8 $ (T.split (\x -> x=='\\' || x =='/')) y)
    linkify x =
      T.concat ["<a href=\"",fileWoExt x,"\">",T.drop 6 x,"</a>"]
    listify x =
      T.concat $ ["<ul><li>"]++intersperse "</li>\n<li>" x++["</li></ul>"]
    p = listify $ map (linkify . shorten . toTextIgnore) files
  in do
    writefile i $ T.concat ["<apply template='base'>\n",p,"</apply>"]


convert_lhs_to_tpl :: Shelly.FilePath -> Sh ()
convert_lhs_to_tpl file =
  let
    filename =  last $ (T.split (\x -> x=='\\' || x =='/')) $ toTextIgnore file
    fileWoExt =  (T.reverse . T.drop 4 . T.reverse . toTextIgnore) file
    nf = fromText (T.concat [fileWoExt,".tpl"]) :: Shelly.FilePath
    code = T.concat ["<markdown file=\"",filename,"\"/>\n"]
  in do
    writefile nf "<apply template='post'>\n"
    appendfile nf $ T.concat ["<h2>",filename,"</h2>\n"]
    appendfile nf code
    appendfile nf "</apply>"


isHaskell :: Shelly.FilePath -> Sh Bool
isHaskell f =
  return (".lhs" == (T.reverse . T.take 4 . T.reverse . toTextIgnore) f)

isIndex :: Shelly.FilePath -> Sh Bool
isIndex f =
  return ("index.tpl" == (T.reverse . T.take 9 . T.reverse . toTextIgnore) f)


{-
lhsToHTML :: T.Text -> T.Text
lhsToHTML i =
  let
    xs = filter (\x->x /="") (T.lines i)
    v1 = "\n<iframe width=\"420\" height=\"315\" src=\""
    v2 = "\" frameborder=\"0\" allowfullscreen></iframe><br>"
    vUrl = T.replace "watch?v=" "embed/" (T.stripEnd $ head xs)
    vid = T.concat [v1,
                    vUrl,
                    v2]
    toCode l =
      if T.head l == '>'
      then T.concat ["<pre>",T.stripEnd $ T.tail l,"</pre>\n"]
      else T.concat ["<p>",T.stripEnd $ l,"</p>\n"]
    o = T.concat $ map toCode $ ([vid] ++ tail xs)
    o' = T.replace "</pre>\n<pre>" "\n" o
    o'' = T.replace "</p>\n<p>" "" o'
  in
    o''
-}
