-- |
-- Module:      Trace.Hpc.Coveralls.Lix
-- Copyright:   (c) 2014 Guillaume Nargeot
-- License:     BSD3
-- Maintainer:  Guillaume Nargeot <guillaume+hackage@nargeot.com>
-- Stability:   experimental
-- Portability: portable
--
-- Functions for converting hpc output to line-based code coverage data.

module Trace.Hpc.Coveralls.Lix where

import Data.List
import Data.Ord
import Prelude hiding (getLine)
import Trace.Hpc.Coveralls.Types
import Trace.Hpc.Coveralls.Util
import Trace.Hpc.Mix
import Trace.Hpc.Util

toHit :: [Bool] -> Hit
toHit [] = Irrelevant
toHit [x] = if x then Full else None
toHit xs
    | and xs = Full
    | or xs = Partial
    | otherwise = None

getLine :: MixEntry -> Int
getLine = fffst . fromHpcPos . fst
    where fffst (x, _, _, _) = x

toLineHit :: (MixEntry, Integer) -> (Int, Bool)
toLineHit (entry, cnt) = (getLine entry - 1, cnt > 0)

-- | Convert hpc coverage entries into a line based coverage format
toLix :: Int                   -- ^ Source line count
      -> [(MixEntry, Integer)] -- ^ Mix entries and associated hit count
      -> Lix                   -- ^ Line coverage
toLix lineCount entries = map toHit (groupByIndex lineCount sortedLineHits)
    where sortedLineHits = sortBy (comparing fst) lineHits
          lineHits = map toLineHit entries
