{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- |
Module      :  Data.Syntax.Printer.ByteString
Description :  Prints to a ByteString Builder using strict ByteString as the sequence.
Copyright   :  (c) Paweł Nowak
License     :  MIT

Maintainer  :  Paweł Nowak <pawel834@gmail.com>
Stability   :  experimental
-}
module Data.Syntax.Printer.ByteString (
    Printer,
    runPrinter
    )
    where

import           Control.Monad
import           Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import           Data.ByteString.Lazy.Builder
import           Data.SemiIsoFunctor
import           Data.Syntax
import           Data.Syntax.Printer.Consumer

-- | Prints a value to a Text Builder using a syntax description.
newtype Printer a = Printer { getConsumer :: Consumer Builder a }
    deriving (SemiIsoFunctor, SemiIsoApply, SemiIsoAlternative, SemiIsoMonad)

instance Syntax Printer ByteString where
    anyChar = Printer . Consumer $ Right . word8
    take n = Printer . Consumer $ Right . byteString . BS.take n
    takeWhile p = Printer . Consumer $ Right . byteString . BS.takeWhile p
    takeWhile1 p = Printer . Consumer $ Right . byteString <=< notNull . BS.takeWhile p
      where notNull t | BS.null t  = Left "takeWhile1 failed"
                      | otherwise = Right t
    takeTill1 p = Printer . Consumer $ Right . byteString <=< notNull . BS.takeWhile (not . p)
      where notNull t | BS.null t  = Left "takeTill1 failed"
                      | otherwise = Right t

-- | Runs the printer.
runPrinter :: Printer a -> a -> Either String Builder
runPrinter = runConsumer . getConsumer