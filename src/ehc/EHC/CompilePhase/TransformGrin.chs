%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EHC Compile XXX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Grin transformation

%%[8 module {%{EH}EHC.CompilePhase.TransformGrin}
%%]

-- general imports
%%[8 import(qualified Data.Map as Map, qualified Data.Set as Set)
%%]

%%[8 import({%{EH}EHC.Common})
%%]
%%[8 import({%{EH}EHC.CompileUnit})
%%]
%%[8 import({%{EH}EHC.CompileRun})
%%]

-- Language syntax: Grin
%%[(8 codegen grin) import(qualified {%{EH}GrinCode} as Grin)
%%]
-- Language syntax: Grin bytecode
%%[(8 codegen grin) import(qualified {%{EH}GrinByteCode} as Bytecode(tagAllowsUnboxedLife))
%%]
-- Output
%%[8 import({%{EH}EHC.CompilePhase.Output(cpOutputGrin)})
%%]

-- Grin transformations
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.UnusedMetaInfoElim}, {%{EH}GrinCode.Trf.UnusedNameElim}, {%{EH}GrinCode.Trf.AliasElim}, {%{EH}GrinCode.Trf.MayLiveUnboxed})
%%]
%%[(8 codegen grin) hs import({%{EH}GrinCode.Trf.ConstPropagation}, {%{EH}GrinCode.Trf.FlattenSeq}, {%{EH}GrinCode.Trf.EvalElim}, {%{EH}GrinCode.Trf.Inline})
%%]
%%[(8_2 codegen grin) hs import({%{EH}GrinCode.Trf.PrettyVarNames})
%%]

-- Heeeel veel Grin-transformaties
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.DropUnreachableBindings(dropUnreachableBindings)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.MemberSelect(memberSelect)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.SimpleNullary(simpleNullary)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.CleanupPass(cleanupPass)})
%%]
%%[(97 codegen grin) import({%{EH}GrinCode.Trf.ConstInt(constInt)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.BuildAppBindings(buildAppBindings)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.GlobalConstants(globalConstants)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.Inline(grInline)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.FlattenSeq(grFlattenSeq)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.SetGrinInvariant(setGrinInvariant)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.CheckGrinInvariant(checkGrinInvariant)})
%%]
%%[(9 codegen grin) import({%{EH}GrinCode.Trf.MergeInstance(mergeInstance)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.EvalStored(evalStored)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.ApplyUnited(applyUnited)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.SpecConst(specConst)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.NumberIdents(numberIdents)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.DropUnusedExpr(dropUnusedExpr)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.PointsToAnalysis(heapPointsToAnalysis)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.InlineEA(inlineEA)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.DropDeadBindings(dropDeadBindings)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.EmptyAlts(emptyAlts)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.LateInline(lateInline)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.ImpossibleCase(impossibleCase)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.SingleCase(singleCase)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.MergeCase(mergeCase)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.LowerGrin(lowerGrin)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.CopyPropagation(copyPropagation)})
%%]
%%[(8 codegen grin) import({%{EH}GrinCode.Trf.SplitFetch(splitFetch)})
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compile actions: transformations, on grin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(8 codegen grin)
cpMsgGrinTrf :: HsName -> String -> EHCompilePhase ()
cpMsgGrinTrf modNm m
  = do { cr <- get
       ; let (_,_,_,fp) = crBaseInfo modNm cr
       ; cpMsg' modNm VerboseALot "Local GRIN optim" (Just m) fp     -- '
       }

cpFromGrinTrf :: HsName -> (Grin.GrModule -> Grin.GrModule) -> String -> EHCompilePhase ()
cpFromGrinTrf modNm trf m
  = do { cr <- get
       ; let (ecu,_,_,fp) = crBaseInfo modNm cr
       ; cpMsgGrinTrf modNm m
       ; cpUpdCU modNm $ ecuStoreGrin $ trf $ fromJust $ ecuMbGrin ecu
       }

cpIterGrinTrf :: HsName -> (Grin.GrModule -> (Grin.GrModule, Bool)) -> String -> EHCompilePhase ()
cpIterGrinTrf modNm trf m = do
    cr <- get
    let (_,_,_,fp) = crBaseInfo modNm cr
    cpMsg' modNm VerboseALot "Local GRIN optim (iterated)" (Just m) fp
    i <- caFixCount 1
    cpMsg' modNm VerboseALot ("  done in " ++ show i ++ " iteration(s)") (Just m) fp
  where caFixCount n = do
          cr <- get
          let (ecu,_,_,_) = crBaseInfo modNm cr
          let code = fromJust $ ecuMbGrin ecu
          (code, changed) <- return $ trf code
          cpUpdCU modNm $ ecuStoreGrin $ code
          if changed then (caFixCount $ n+1) else return n

cpFullGrinTrf :: HsName -> ([Grin.GrModule] -> Grin.GrModule -> Grin.GrModule) -> String -> EHCompilePhase ()
cpFullGrinTrf modNm trf m
  = do { cr <- get
       ; imps <- allImports modNm
       ; let (_,_,_,fp) = crBaseInfo modNm cr
       ; cpMsg' modNm VerboseALot ("Full GRIN optim, using " ++ show imps) (Just m) fp
       ; let theGrin nm = case crBaseInfo nm cr of (ecu,_,_,_) -> fromJust $ ecuMbGrin ecu
       ; cpUpdCU modNm $ ecuStoreGrin $ trf (map theGrin imps) $ theGrin modNm
       }

%%]

%%[(8 codegen grin) export(cpTransformGrin)
allImports :: HsName -> EHCompilePhase [HsName]
allImports modNm = do
  cr <- get
  let (ecu,_,_,_) = crBaseInfo modNm cr
  let imps        = ecuImpNmL ecu
  rec <- mapM allImports imps
  return $ nub (concat (imps : rec))

cpTransformGrin :: HsName -> EHCompilePhase ()
cpTransformGrin modNm
  =  do  {  cr <- get
         ;  imports    <- allImports modNm
         ;  let  (ecu,_,opts,_) = crBaseInfo modNm cr
                 fullProg    = ehcOptFullProgAnalysis opts
                 forBytecode = not fullProg
                 optimizing  = ehcOptOptimise opts >= OptimiseNormal
         
{- for debugging 
                 trafos  =     mk [mte,unb,flt,cpr,nme]
-}
                 trafos  =     (if forBytecode               then mk [metaElim, unbox]            else [])
                           ++  (if optimizing                then mk evel                         else mk [flatten])
                           ++  (if forBytecode && optimizing then inline : mk (evel++[constProp]) else [])
                           ++  (if optimizing                then mk [nameElim]                   else [])
                           ++  (if fullProg                  then grPerModuleFullProg modNm       else [])

                   where mk            = map mk1
                         mk1 (trf,msg) = (cpFromGrinTrf modNm trf msg, msg)

                         flatten    = ( grFlattenSeq                   , "flatten"          )
                         aliasElim  = ( grAliasElim                    , "alias elim"       )
                         nameElim   = ( grUnusedNameElim               , "unused name elim" )
                         evalElim   = ( grEvalElim opts                , "eval elim"        )
                         metaElim   = ( grUnusedMetaInfoElim           , "meta info elim"   )
                         constProp  = ( grConstPropagation             , "const prop"       )
                         unbox      = ( grMayLiveUnboxed (Bytecode.tagAllowsUnboxedLife opts)
                                                                 , "unbox"            )
%%[[8_2
                         uniform    = ( grPrettyNames                  , "rename uniform"   ) 
%%]]
%%[[8
                         evel = [ flatten, aliasElim, evalElim, flatten, aliasElim ]
%%][8_2
                         evel = [ flatten, aliasElim, uniform, evalElim, flatten, aliasElim ]
%%]]
%%[[8                              
                         inline = mk1 ( grInline True , "inline" )
%%][20                                
                         inline = ( do { cr <- get
                                       ; let (ecu,crsi,_,_) = crBaseInfo modNm cr
                                             expNmOffMp     = crsiExpNmOffMp modNm crsi
                                             optim          = crsiOptim crsi
                                             (g,gathInlMp)  = grInline True (Map.keysSet expNmOffMp) (optimGrInlMp optim) $ fromJust $ ecuMbGrin ecu
                                       ; cpMsgGrinTrf modNm "inline"
                                       ; cpUpdCU modNm (ecuStoreOptim (defaultOptim {optimGrInlMp = gathInlMp}) . ecuStoreGrin g)
                                       }
                                  , "inline" 
                                  ) 
%%]]                              
                              
                 optGrinNormal = map fst trafos
                 optGrinDump   = out 0 "from core" : concat [ [o,out n nm] | (n,(o,nm)) <- zip [1..] trafos ]
                        where out n nm = cpOutputGrin False ("-0" ++ show (10+n) ++ "-" ++ filter isAlpha nm) modNm
         ;  when (isJust $ ecuMbGrin ecu)
                 (cpSeq (if ehcOptDumpGrinStages opts then optGrinDump else optGrinNormal))
         }


grPerModuleFullProg :: HsName -> [(EHCompilePhase (), String)]
grPerModuleFullProg modNm = mk trafos1 ++ invariant ++ grSpecialize modNm ++ mk [dropUnreach] ++ invariant
  where
    trafos1 =
      [ dropUnreach
%%[[9
      , ( mergeInstance                 , "MergeInstance"           )
      , ( memberSelect                  , "MemberSelect"            )
    
      , dropUnreach
%%]]
      , ( cleanupPass                   , "CleanupPass"             )
      , ( simpleNullary                 , "SimpleNullary"           )
%%[[97
      , ( constInt                      , "ConstInt"                )
%%]]
      , ( buildAppBindings              , "BuildAppBindings"        )
      , ( globalConstants               , "GlobalConstants"         )
%%[[8
      , ( grInline False                , "Inline"                  )
%%][20
      , ( fst . grInline False Set.empty Map.empty, "Inline"        )
%%]]
      , ( grFlattenSeq                  , "Flatten"                 )
    
      , ( singleCase                    , "singleCase"              )
      , ( grFlattenSeq                  , "Flatten"                 )
    
      , ( setGrinInvariant              , "SetGrinInvariant"        )
      ]

    dropUnreach = ( id {- dropUnreachableBindings False -} , "DropUnreachableBindings stub" )
    invariant = mk [(setGrinInvariant, "SetGrinInvariant")] ++ [(checkInvariant, "CheckGrinInvariant")]

    checkInvariant =
      do { cr <- get
         ; imps <- allImports modNm
         ; let theGrin nm     = case crBaseInfo nm cr of (ecu,_,_,_) -> fromJust $ ecuMbGrin ecu
               errors         = checkGrinInvariant (map theGrin imps) $ theGrin modNm
         ; cpMsgGrinTrf modNm "CheckGrinInvariant"
         ; when (not (null errors)) (error (unlines errors))
         }

    mk            = map mk1
    mk1 (trf,msg) = (cpFromGrinTrf modNm trf msg, msg)
    

-- grSpecialize :: [(Grin.GrModule -> Grin.GrModule, String)]
grSpecialize modNm = concat $ replicate 6 $
    [ once evalStored                        "eval stored"
    , once applyUnited                       "apply united"
    , once grFlattenSeq                      "flatten"
    -- , iter dropUnusedExpr                    "drop unused"
    , full specConst                         "spec const"
    , iter copyPropagation                   "copy prop"
    , once singleCase                        "single case"
    , once grFlattenSeq                      "flatten"
    , once simpleNullary                     "simply nullary"
    , once memberSelect                      "member select"
    -- , once (dropUnreachableBindings False)   "drop unreachable"
    ]
  where once trf m = (cpFromGrinTrf modNm trf m, m)
        iter trf m = (cpIterGrinTrf modNm trf m, m)
        full trf m = (cpFullGrinTrf modNm trf m, m)

%%]

