{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
import Shelly
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
  let x = (dir </> "snaplets" </> "heist" </> "templates" </> "posts")
  files <- findWhen isHaskell x
  return files



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
