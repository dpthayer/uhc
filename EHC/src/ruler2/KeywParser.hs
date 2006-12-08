-------------------------------------------------------------------------
-- Keyw/sym parser
-------------------------------------------------------------------------

module KeywParser
  ( specialChars, opChars
  , propsSynInhMp, propsDirMp, propsMp
  
  , keywordsTextDir
  , keywordsTextProps, keywordsTextEscapable, keywordsText
  , keywordsOpsEsc, keywordsOpsExplainEsc, keywordsOpsParenEsc
  , keywordsOps
  
  , mkScan, mkHScan, mkOffScan
  
  , pKeySPos
  , pNmStr, pNmStrSPos
  , pNmStrI, pNmStrISPos
  , pSymEscStr, pSymEscStrSPos
  , pSymStr, pSymStrSPos
  
  )
  where

import qualified Data.Map as Map
import IO
import UU.Parsing
-- import UUTest.Parsing.Offside
import UU.Parsing.Offside
import RulerScanner
import RulerConfig
import EH.Util.ParseUtils
import AttrProps
import EH.Util.ScanUtils

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Scanning
-------------------------------------------------------------------------

specialChars  =  "().`"
opChars       =  "!#$%&*+/<=>?@\\^|-:;,[]{}~"

propsSynInhMp
  =  Map.fromList [ ("thread",AtThread), ("updown",AtUpdown) ]
propsOtherMp
  =  Map.fromList [ ("retain",AtRetain), ("node",AtNode), ("extern",AtExtern) ]
propsDirMp
  =  Map.fromList [ ("inh",AtInh), ("syn",AtSyn) ]
propsMp
  =  Map.unions [ propsSynInhMp, propsOtherMp, propsDirMp ]
keywordsTextProps
  =  Map.keys propsMp
keywordsTextDir
  =  Map.keys propsDirMp
keywordsTextEscapable
  =  keywordsTextProps
     ++ [ "judge", "judgeshape", "judgespec", "judgeuse", "relation"
        , "rule", "rules", "ruleset"
        , "scheme", "view", "hole", "holes", "viewsel", "rulesgroup"
        , "explain"
        , "data"
        -- related to global info
        , "viewhierarchy", "format", "rewrite", "preamble"
        , "extern", "external"
        , "include"
        -- related to formatting (styles)
        , "tex", "fmtcmd", "ag", "def", "use", "spec"
        -- misc
        , "text"
        ]
keywordsOffsideTrigs
  =  [ "judges"
     ]
keywordsText
  =  [ "unique"
     ] ++ keywordsOffsideTrigs
       ++ keywordsTextEscapable
keywordsOpsEsc
  =  cfgKeywordsOpsEsc
keywordsOpsExplainEsc
  =  [ cfgStrSel ] ++ cfgKeywordsOpsExplainEsc
keywordsOpsParenEsc
  =  [ "|" ] ++ keywordsOpsExplainEsc
keywordsOps
  =  keywordsOpsParenEsc ++ keywordsOpsEsc

rulerScanOpts :: ScanOpts
rulerScanOpts
  = defaultScanOpts
      { scoKeywordsTxt   = keywordsText
      , scoKeywordsOps   = keywordsOps
      , scoSpecChars     = specialChars
      , scoOpChars       = opChars
      , scoOffsideTrigs  = keywordsOffsideTrigs
      , scoOffsideModule = ""
      , scoOffsideOpen   = ""
      , scoOffsideClose  = ""
      }

mkScan :: FilePath -> String -> [Token]
mkScan fn txt = scan rulerScanOpts (initPos fn) txt

mkHScan :: FilePath -> Handle -> IO [Token]
mkHScan fn fh
  = do  {  txt <- hGetContents fh
        ;  return (mkScan fn txt) 
        }

mkOffScan :: FilePath -> Handle -> IO (OffsideInput [Token] Token (Maybe Token))
mkOffScan = offsideScanHandle rulerScanOpts

-------------------------------------------------------------------------
-- Parser
-------------------------------------------------------------------------

pKeySPos :: (IsParser p Token) => String -> p SPos
pKeySPos k  = (\p -> (k,p)) <$> pKeyPos k

pNmStrSPos, pNmStrISPos :: (IsParser p Token) => p SPos
pNmStrSPos = pVaridPos <|> pConidPos
pNmStrISPos = pNmStrSPos <|> pIntegerPos

pNmStr, pNmStrI :: (IsParser p Token) => p String
pNmStr = fst <$> pNmStrSPos
pNmStrI = fst <$> pNmStrISPos

pSymEscStrSPos :: (IsParser p Token) => ([String],[String]) -> p SPos
pSymEscStrSPos (kEsc,kpEsc)
  =   pVarsymPos <|> pConsymPos
  <|> pAnyKey pKeySPos kEsc
  <|> pKey "`"  *> (   (\(n,p) -> ("`" ++ n ++ "`",p)) <$> pNmStrSPos
                   <|> (\nl@((_,p):_) -> (concat (map fst nl),p)) <$> pList1 (pAnyKey pKeySPos kpEsc)
                   )
               <*  pKey "`"

pSymEscStr :: (IsParser p Token) => ([String],[String]) -> p String
pSymEscStr k = fst <$> pSymEscStrSPos k

pSymStrSPos :: (IsParser p Token) => p SPos
pSymStrSPos = pSymEscStrSPos (keywordsOpsEsc,keywordsOpsParenEsc)

pSymStr :: (IsParser p Token) => p String
pSymStr = pSymEscStr (keywordsOpsEsc,keywordsOpsParenEsc)
