{-# LANGUAGE OverloadedStrings #-}

module Stock where

import           Heist
import qualified Heist.Compiled as C
import           Data.Text (Text)
import           System.IO.Unsafe 
import           Data.Int (Int64)

---------------------------------------
import           StockPrices
---------------------------------------

data Stock = Stock {
    stockId :: Maybe Int64,
    number :: Text,
    ticker :: Text
} deriving Show


--this is where a database call could go
stocksRuntime :: Monad n => RuntimeSplice n [Stock]
stocksRuntime = return [  Stock (Just 1) "10" "AAPL"
                        , Stock (Just 2) "20" "GOOG"
                        ]

splicesFromStock :: Monad n => Splices (RuntimeSplice n Stock -> C.Splice n)
splicesFromStock = mapS (C.pureSplice . C.textSplice) $ do
  "stockNumber"  ## number
  "stockTicker"  ## ticker
  "stockPrice"   ## unsafePerformIO.tToP.ticker

renderStocks :: Monad n => RuntimeSplice n [Stock] -> C.Splice n
renderStocks = C.manyWithSplices C.runChildren splicesFromStock

allStockSplices :: Monad n => Splices (C.Splice n)
allStockSplices =
  "allStocks" ## (renderStocks stocksRuntime)


