> {-# LANGUAGE OverloadedStrings #-}

to start we just want to have a function that can
take a ticker and give the price

> module StockPrices where

> import           Network.HTTP.Conduit
> import qualified Data.ByteString.Lazy.Char8 as C
> import           Data.Text (Text)
> import qualified Data.Text as T
> import qualified Data.Text.Encoding as TE
> import           Control.Applicative
> import           Text.XML.HXT.Core 

This will need to be replaced with a better API service
too much delay, but a working demo for now

> tToP :: Text -> IO(Text)
> tToP t = do
>    --let url = T.concat ["http://download.finance.yahoo.com/d/quotes.csv?s=",t,"&f=l1&e=.csv"]
>    let url = T.concat ["http://dev.markitondemand.com/Api/v2/Quote/xml?symbol=",t]
> --  c <- fromURL $ T.unpack url
>    
> --   return $ T.pack $ C.unpack url
>    return $ T.pack "test"

 main :: IO()
 main = do
   print "enter a ticker"
   t <- getLine
   price <- tToP t
   print price
   main
