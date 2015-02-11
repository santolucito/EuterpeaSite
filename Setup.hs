{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
import Shelly
import Control.Monad
import qualified Data.Text as T
default (T.Text)

main = do
  f <-shelly preBuild
  print f

isHaskell :: Shelly.FilePath -> Sh Bool
isHaskell f =
  return (".lhs" == (T.reverse . T.take 4 . T.reverse . toTextIgnore) f)

preBuild  = do
  dir   <- pwd
  let p = (dir </> "snaplets" </> "heist" </> "templates" </> "posts")
  files <- findWhen isHaskell p
  forM files convertFileToHtml
  return files

convertFileToHtml :: Shelly.FilePath -> Sh ()
convertFileToHtml file =
  let
    f =  (T.reverse . T.drop 4 . T.reverse . toTextIgnore) file
    nf = fromText (T.concat [f,".tpl"]) :: Shelly.FilePath
  in do
    writefile nf "<apply template='post'>"
    contents <- readfile file
    let newC = lhsToHTML contents
    appendfile nf newC
    appendfile nf "</apply>"

lhsToHTML :: T.Text -> T.Text
lhsToHTML i =
  let
    xs = filter (\x->x /="") (T.lines i)
    v1 = "\n<iframe width=\"420\" height=\"315\" src=\""
    v2 = "\" frameborder=\"0\" allowfullscreen></iframe>"
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



{-  forM files convertFileToHtml
  return (Nothing, [])

search pat dir =
  F.find always (fileName ~~? pat) dir

convertToHtml =
  (writeHtmlString
     def{writerHighlight = True,
         writerExtensions = githubMarkdownExtensions}) .
   readMarkdown def

convertFileToHtml file =
  let newFile = replaceExtension file "tpl"
      dir = takeDirectory file
  in do
    writeFile newFile "<apply template='post'><bind tag='post'>"
    readFile file >>= appendFile newFile . convertToHtml
    appendFile newFile "</bind></apply>"
-}
