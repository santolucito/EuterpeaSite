{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
import Shelly
import Control.Monad
import Data.List
import qualified Data.Text as T
default (T.Text)

--pretty sure this won't work on windows with their terrible file system

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
    shorten n y = 
      tc $ intersperse "/" (lastN n $ (T.splitOn "/" y))
    htmlLink x = toHtmlLink (fileWoExt x) (shorten 2 x)
    toHtmlList x =
      tc $ ["<ul><li>"]++intersperse "</li>\n<li>" x++["</li></ul>"]
    p = toHtmlList $ map (htmlLink . shorten 3 . toTextIgnore) (sort files)
  in do
    writefile i $ tc ["<apply template='lander'>\n",p,"</apply>"]


convert_lhs_to_tpl :: Shelly.FilePath -> Sh ()
convert_lhs_to_tpl file =
  let
    tfile = toTextIgnore file
    filename =  last $ (T.splitOn "/") $ tfile
    nf = fromText (tc [fileWoExt $ tfile,".tpl"]) :: Shelly.FilePath
    code = tc ["<markdown file=\"",filename,"\"/>\n"] 
    title = toHtmlLink 
             (tc [github, tc $ intersperse "/" $ lastN 2 $ T.splitOn "/" tfile])
             (tc ["<h2>",filename,"</h2>\n"])
  in do
    writefile nf "<apply template='post'>\n"
    appendfile nf title
    appendfile nf code
    appendfile nf "</apply>"


isHaskell :: Shelly.FilePath -> Sh Bool
isHaskell f =
  return ("lhs" == (last . T.splitOn "." . toTextIgnore) f)

isIndex :: Shelly.FilePath -> Sh Bool
isIndex f =
  return ("index.tpl" == (last . T.splitOn "/" . toTextIgnore) f)

--take last n elem
lastN :: Int -> [a] -> [a]
lastN n xs = foldl (const . tail) xs (drop n xs)
    
fileWoExt = tc . init . T.splitOn "."

tc = T.concat
      
toHtmlLink link text =
  tc ["<a href=\"",link,"\">", text,"</a>"]

github = "https://github.com/santolucito/EuterpeaSite/tree/master/snaplets/heist/templates/posts/"

{-
lhsToHTML :: T.Text -> T.Text
lhsToHTML i =
  let
    xs = filter (\x->x /="") (T.lines i)
    v1 = "\n<iframe width=\"420\" height=\"315\" src=\""
    v2 = "\" frameborder=\"0\" allowfullscreen></iframe><br>"
    vUrl = T.replace "watch?v=" "embed/" (T.stripEnd $ head xs)
    vid = tc [v1,
                    vUrl,
                    v2]
    toCode l =
      if T.head l == '>'
      then tc ["<pre>",T.stripEnd $ T.tail l,"</pre>\n"]
      else tc ["<p>",T.stripEnd $ l,"</p>\n"]
    o = tc $ map toCode $ ([vid] ++ tail xs)
    o' = T.replace "</pre>\n<pre>" "\n" o
    o'' = T.replace "</p>\n<p>" "" o'
  in
    o''
-}
