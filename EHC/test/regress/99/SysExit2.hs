{- ----------------------------------------------------------------------------------------
   what    : exit program with success code
   expected: ok
   constraints: exclude-if-jscript
---------------------------------------------------------------------------------------- -}

module SysExit2 where

import System.Exit

main :: IO ()
main
  = do exitSuccess
