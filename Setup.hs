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
  return (".lhs" == (reverse . take 4 . reverse . T.unpack . toTextIgnore) f)

preBuild  = do
  dir   <- pwd
  let p = (dir </> "snaplets" </> "heist" </> "templates" </> "posts")
  files <- findWhen isHaskell p
  forM files convertFileToHtml
  return files

convertFileToHtml :: Shelly.FilePath -> Sh ()
convertFileToHtml file =
  let
    f =  toTextIgnore file
    nf = fromText (T.concat [f,".tpl"]) :: Shelly.FilePath
  in do
    writefile nf "<apply template='post'><bind tag='post'>"
    readfile file >>= appendfile nf
    appendfile nf "</bind></apply>"


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
