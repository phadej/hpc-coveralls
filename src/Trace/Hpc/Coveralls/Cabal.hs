-- |
-- Module:      Trace.Hpc.Coveralls.Cabal
-- Copyright:   (c) 2014-2015 Guillaume Nargeot
-- License:     BSD3
-- Maintainer:  Guillaume Nargeot <guillaume+hackage@nargeot.com>
-- Stability:   experimental
--
-- Functions for reading the cabal package name and version.

module Trace.Hpc.Coveralls.Cabal where

import Control.Applicative
import Control.Monad
import Data.List (isSuffixOf)
import Distribution.Package
import Distribution.PackageDescription
import Distribution.PackageDescription.Configuration
import Distribution.PackageDescription.Parse
import Distribution.Version
import System.Directory

getCabalFile :: IO (Maybe FilePath)
getCabalFile = do
    cnts <- (filter isCabal <$> getDirectoryContents ".") >>= filterM doesFileExist
    case cnts of
        [file] -> return $ Just file
        _ -> return Nothing
    where isCabal filename = ".cabal" `isSuffixOf` filename && length filename > 6

getPackageNameVersion :: FilePath -> IO (Maybe String)
getPackageNameVersion file = do
    orig <- readFile "lens.cabal"
    case parsePackageDescription orig of
        ParseFailed _ -> return Nothing
        ParseOk _warnings gpd -> do
            let pkg = package . packageDescription $ gpd
                PackageName name = pkgName pkg
                version = pkgVersion pkg
            return $ Just $ name ++ "-" ++ show version