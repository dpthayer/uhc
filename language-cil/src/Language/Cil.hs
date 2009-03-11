-- |
-- A simple abstraction over the Common Intermediate Language (also known as
-- MSIL - Microsoft Intermediate Language).
-- Currently, it only exposes a small subset of CIL.
--

-- !! Note: The parser stuff is commented out, since it is horribly broken.

module Language.Cil (
    module Language.Cil.Analysis
  , module Language.Cil.Build
--  , module Language.Cil.Parser
  , module Language.Cil.Pretty
  , module Language.Cil.Syntax
--  , scanAssembly
--  , parseAssembly
  ) where

import Control.Monad (liftM)
import UU.Scanner.Token (Token)

import Language.Cil.Analysis
import Language.Cil.Build
import Language.Cil.Parser
import Language.Cil.Pretty
import Language.Cil.Scanner
import Language.Cil.Syntax

scanAssembly :: FilePath -> IO [Token]
scanAssembly path = do
  src <- readFile path
  return $ scan path src

parseAssembly :: FilePath -> IO Assembly
parseAssembly = liftM (parse pAss) . scanAssembly

