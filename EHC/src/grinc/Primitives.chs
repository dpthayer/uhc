%%[8 hs module {%{GRIN}Primitives}
%%]

This file contains utility functions for primitives in GRIN as well as the
primitives information table.

(ffi "prim...")

- abstract values representing the result of a primitive operation in the HPT analysis
- meta info for code generation
- code snippets to generate the code for a primitive (C--)

%%[8.abstractValues import({%{GRIN}HeapPointsToFixpoint},{%{EH}Base.HsName}, qualified Data.Set as Set, {%{EH}GrinCode},{%{GRIN}GRINCCommon}) export(avForArity)


avForArity = if grinStoreArity
              then [AV_Basic]
              else []


undefinedAV  = AV_Nodes $ Map.fromList [ (GrTag_Lit GrTagCon 0 (HNm "False"), avForArity)
                                       ]
                                       -- HPT-analysis seems to insist that there is at least one value here,
                                       -- so an arbitrary value (False) is inserted in this list.
                                       -- as fun_undefined exits the program, this value is never really used. --JF

unboxedBasic = AV_Nodes $ Map.fromList [ (GrTag_Unboxed, [AV_Basic])
                                       ]
booleanNodes = AV_Nodes $ Map.fromList [ 
                                         (GrTag_Lit GrTagCon 0 (HNm "False"), avForArity)
                                       , (GrTag_Lit GrTagCon 1 (HNm "True" ), avForArity)
                                       ]
compareNodes = AV_Nodes $ Map.fromList [ 
                                       {-
                                         (GrTag_Lit GrTagCon 0 (HNm "EQ"), avForArity)
                                       , (GrTag_Lit GrTagCon 1 (HNm "GT"), avForArity)
                                       , (GrTag_Lit GrTagCon 2 (HNm "LT"), avForArity)
                                       -}
                                       ]
%%]

%%[8.codeGeneration 

{-
--buildin datatype
true_tag   = cmmVar "@C$True"
false_tag  = cmmVar "@C$False"
eq_tag     = cmmVar "@C$EQ"
lt_tag     = cmmVar "@C$LT"
gt_tag     = cmmVar "@C$GT"

true_node   = [true_tag , int 0]
false_node  = [false_tag, int 0]
eq_node     = [eq_tag   , int 0]
lt_node     = [lt_tag   , int 0]
gt_node     = [gt_tag   , int 0]

-- emitting code for primitives
emitPrimModInt (l:r:[]) tn = assignOrReturn tn [(cmmVar l <%> cmmVar r)]
emitPrimDivInt (l:r:[]) tn = assignOrReturn tn [(cmmVar l </> cmmVar r)]
emitPrimMulInt (l:r:[]) tn = assignOrReturn tn [(cmmVar l <*> cmmVar r)]
emitPrimAddInt (l:r:[]) tn = assignOrReturn tn [(cmmVar l <+> cmmVar r)]
emitPrimSubInt (l:r:[]) tn = assignOrReturn tn [(cmmVar l <-> cmmVar r)]

emitPrimGtInt = booleanCompare "gt"
emitPrimLtInt = booleanCompare "lt"
emitPrimEqInt = booleanCompare "eq"

booleanCompare s (l:r:[]) (Right (t:f:[])) = ite (prim s [valArg $ cmmVar l, valArg $ cmmVar r]) t f

emitPrimCmpInt (l:r:[]) tn
  = ite (prim "gt" [valArg $ cmmVar l,valArg $ cmmVar r])
        (assignOrReturn tn gt_node)
        (ite (prim "lt" [valArg $ cmmVar l,valArg $ cmmVar r])
             (assignOrReturn tn lt_node)
             (assignOrReturn tn eq_node)
        )

assignOrReturn (Left tn) expr = if null tn
                                then cmmReturn "" (map valArg expr)
                                else updates (zipWith (\l r -> (varUpdate l,r)) tn expr)
-}

emitPrimAddInt = undefined
emitPrimSubInt = undefined
emitPrimMulInt = undefined
emitPrimDivInt = undefined
emitPrimModInt = undefined
emitPrimEqInt = undefined
emitPrimLtInt = undefined
emitPrimGtInt = undefined
emitPrimCmpInt = undefined


%%]

%%[8.primitivesMap import(qualified Data.Map as Map)

{-
type PrimitiveInfo = (Int
                     , [String]
                     , CmmNames -> Either CmmNames [CmmBodyBuilder] -> CmmBodyBuilder
                     , AbstractValue
                     )

primitivesMap  ::  Map.Map String PrimitiveInfo
-}


primitivesMap  =   Map.fromList primitivesTable
    where
    -- primitivesTable: list of name |-> (return size, required imports, arguments -> result vars or bodies -> primitive, AV)
    primitivesTable
      =  [ ("primAddInt"   , (1, [], emitPrimAddInt,  unboxedBasic))
         , ("primSubInt"   , (1, [], emitPrimSubInt,  unboxedBasic))
         , ("primMulInt"   , (1, [], emitPrimMulInt,  unboxedBasic))
         , ("primDivInt"   , (1, [], emitPrimDivInt,  unboxedBasic))
         , ("primModInt"   , (1, [], emitPrimModInt,  unboxedBasic))
         , ("primShlWord"  , (1, [], undefined     ,  unboxedBasic))
         , ("primShrWord"  , (1, [], undefined     ,  unboxedBasic))
         , ("primAndWord"  , (1, [], undefined     ,  unboxedBasic))
         , ("primXorWord"  , (1, [], undefined     ,  unboxedBasic))
         , ("primOrWord"   , (1, [], undefined     ,  unboxedBasic))
         , ("primUndefined", (1, [], undefined     ,  undefinedAV ))
         , ("primEqInt"    , (2, [], emitPrimEqInt ,  booleanNodes))
         , ("primLtInt"    , (2, [], emitPrimLtInt ,  booleanNodes))
         , ("primGtInt"    , (2, [], emitPrimGtInt ,  booleanNodes))
         , ("primCmpInt"   , (2, [], emitPrimCmpInt,  compareNodes))
        ]
%%]

%%[8.utils export(isPrim,isConditionalPrim,codeGenInfo,primAV)
isPrim             = ("prim" ==) . take 4
isConditionalPrim  = flip elem ["primEqInt", "primLtInt", "primGtInt"]

--getPrimInfo :: (PrimitiveInfo -> b) -> String -> b
getPrimInfo f prim = f (Map.findWithDefault (error $ "prim '" ++ prim ++ "' not found!") prim primitivesMap)

-- primSize     =  getPrimInfo (\ (a, _, _, _) -> a)
-- primImports  =  getPrimInfo (\ (_, b, _, _) -> b)
-- primCode     =  getPrimInfo (\ (_, _, c, _) -> c)
primAV       =  getPrimInfo (\ (_, _, _, d) -> d)
codeGenInfo  =  getPrimInfo (\ (a, b, c, _) -> (a, b, c))
%%]

%%[12 import({%{EH}Base.Builtin},{%{GRIN}Config}) export(hsnToGlobal)
-- primitive related names which should be globally available, in unqualified form
primGlobalNames :: Set.Set HsName
primGlobalNames
  = Set.fromList
  $ map (hsnPrefix rtsGlobalVarPrefix . hsnQualified)
  $ [ hsnTrue, hsnFalse
%%[[99
    , hsnEQ, hsnLT, hsnGT
%%]]
    ]

hsnToGlobal :: HsName -> HsName
hsnToGlobal n
  = if n2 `Set.member` primGlobalNames then n2 else n
  where n2 = hsnQualified n
%%]

