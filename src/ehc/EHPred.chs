%%[0
%include lhs2TeX.fmt
%include afp.fmt
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pred
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9 module {%{EHC}Pred} import(Data.Maybe,Data.List,qualified Data.Map as Map,qualified Data.Set as Set,UU.Pretty)
%%]

%%[9 import(EHTy,EHTyPretty,{%{EHC}TyFitsInCommon},EHTyQuantify,EHCore,EHCorePretty,EHCoreSubst,{%{EHC}Common},{%{EHC}Gam},{%{EHC}Cnstr},{%{EHC}Substitutable})
%%]

%%[9 import({%{EHC}Debug})
%%]

%%[9 import(EHError) export(ProofState(..))
%%]

%%[9 export(ProvenNode(..),prvnIsAnd)
%%]

%%[9 export(ProvenGraph(..),prvgAddPrNd,prvgAddPrUids,prvgAddNd,prvgBackToOrig,prvgReachableFrom,prvgReachableTo,prvgIsFact,prvgFactL)
%%]

%%[9 export(prvgCxBindLMap,prvgIntroBindL,prvgLetHoleCSubst)
%%]

%%[9 export(prvg2ReachableFrom)
%%]

%%[9 export(Rule(..),emptyRule,mkInstElimRule)
%%]

%%[9 export(ProofCost(..),mkCost,mkCostAvailImpl,costVeryMuch,costAvailArg,costZero,costNeg,costAdd,costBase,costAddHi,costMulBy)
%%]

%%[9 export(ClsFuncDep(..))
%%]

%%[9 export(PrIntroGamInfo(..),PrIntroGam,emptyPIGI)
%%]

%%[9 export(PrElimGamInfo(..))
%%]

%%[9 export(PrElimTGam,peTGamAdd,peTGamDel,peTGamAddKnPr,peTGamAddKnPrL,peTGamPoiS)
%%]

%%[9 import(EHTyFtv) export(prvgArgLeaves,prvgSatisfiedNodeS,prvgOrigs,prvgAppPoiSubst,prvg2BackMp,prvgShareMp)
%%]

%%[9 export(PoiSubst(..),PoiSubstitutable(..))
%%]

%%[9 export(prfsAddPrOccL)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Substitution for PredOccId
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
newtype PoiSubst = PoiSubst {poisMp :: Map.Map PredOccId PredOccId}
%%]

%%[9
infixr `poisApp`

class PoiSubstitutable a where
  poisApp :: PoiSubst -> a -> a

instance PoiSubstitutable PredOccId where
  poisApp (PoiSubst m) poi = maybe poi id . Map.lookup poi $ m

instance PoiSubstitutable a => PoiSubstitutable [a] where
  poisApp s = map (poisApp s)

instance PoiSubstitutable PoiSubst where
  poisApp (PoiSubst m1) (PoiSubst m2)
    = PoiSubst (m1 `Map.union` Map.map (\i -> maybe i id (Map.lookup i m1)) m2)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data ProofCost  = Cost {costHi, costLo :: Int}
                deriving (Eq,Show)

instance Ord ProofCost where
  (Cost h1 l1) `compare` (Cost h2 l2)
    | hcmp == EQ  = l1 `compare` l2
    | otherwise   = hcmp
    where hcmp = h1 `compare` h2

mkCost :: Int -> ProofCost
mkCost c = Cost 0 c

costVeryMuch    = Cost 100 0
costZero        = mkCost 0
costBase        = mkCost 1
costAvailArg    = mkCost 2
costNeg         = Cost (-2) 0

mkCostAvailImpl :: Int -> ProofCost
mkCostAvailImpl c = Cost (-1) c

infixr 2 `costAdd`, `costAddHi`
infixr 3 `costMulBy`

costMulBy :: ProofCost -> Int -> ProofCost
c1@(Cost h l) `costMulBy` i = Cost h (l * i)

costAdd :: ProofCost -> ProofCost -> ProofCost
c1@(Cost h1 l1) `costAdd` c2@(Cost h2 l2) = Cost (h1 + h2) (l1 + l2)

costAddHi :: ProofCost -> Int -> ProofCost
(Cost h l) `costAddHi` i = Cost (h+i) l

instance PP ProofCost where
  pp (Cost h l) = "C:" >|< pp h >|< ":" >|< l
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pred resolver, proven nodes in proven graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data ProvenNode
  =  ProvenOr       { prvnPred           :: Pred            , prvnEdges         :: [PredOccId]
                    , prvnCost           :: ProofCost
                    }
  |  ProvenAnd      { prvnPred           :: Pred
                    , prvnEdges          :: [PredOccId]     , prvnLamEdges      :: [PredOccId]
                    , prvnCost           :: ProofCost       , prvnEvid          :: CExpr
                    }
  |  ProvenShare    { prvnPred           :: Pred            , prvnEdge          :: PredOccId    }
  |  ProvenArg      { prvnPred           :: Pred            , prvnCost          :: ProofCost    }

prvnIsAnd :: ProvenNode -> Bool
prvnIsAnd (ProvenAnd _ _ _ _ _) = True
prvnIsAnd _                     = False

prvnIsArg :: ProvenNode -> Bool
prvnIsArg (ProvenArg _ _) = True
prvnIsArg _               = False

instance Show ProvenNode where
  show _ = ""

instance PP ProvenNode where
  pp (ProvenOr  pr es c         )   = "OR:"    >#< "pr=" >|< pp pr >#< "edges=" >|< ppCommaList es                                      >#< "cost=" >|< pp c
  pp (ProvenAnd pr es les c ev  )   = "AND:"   >#< "pr=" >|< pp pr >#< "edges=" >|< ppCommaList es >#< "lamedges=" >|< ppCommaList les  >#< "cost=" >|< pp c >#< "evid=" >|< pp ev
  pp (ProvenShare pr e          )   = "SHARE:" >#< "pr=" >|< pp pr >#< "edge="  >|< ppCommaList [e]
  pp (ProvenArg pr c            )   = "ARG:"   >#< "pr=" >|< pp pr                                                                      >#< "cost=" >|< pp c
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pred resolver, proven graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data ProvenGraph
  =  ProvenGraph
       { prvgIdNdMp             :: Map.Map PredOccId ProvenNode
       , prvgPrIdMp             :: Map.Map Pred [PredOccId]
       , prvgPrOrigIdMp         :: Map.Map Pred [PredOccId]
       , prvgPrUsedFactIdMp     :: Map.Map Pred [PredOccId]
       }

prvgAddPrUids :: Pred -> [PredOccId] -> ProvenGraph -> ProvenGraph
prvgAddPrUids pr uidL g@(ProvenGraph _ p2i _ _)
  =  g {prvgPrIdMp = Map.insertWith (++) pr uidL p2i}

prvgAddNd :: PredOccId -> ProvenNode -> ProvenGraph -> ProvenGraph
prvgAddNd uid nd g@(ProvenGraph i2n _ _ _)
  =  g {prvgIdNdMp = Map.insert uid nd i2n}

prvgAddPrNd :: Pred -> [PredOccId] -> ProvenNode -> ProvenGraph -> ProvenGraph
prvgAddPrNd pr uidL@(uid:_) nd
  =  prvgAddPrUids pr uidL . prvgAddNd uid nd

instance Show ProvenGraph where
  show _ = ""

instance PP ProvenGraph where
  pp (ProvenGraph i2n p2i p2oi p2fi)
    =      "Pr->Ids  :" >#< pp2i p2i
       >-< "Id->Nd   :" >#< ppAssocLV (Map.toList i2n)
       >-< "Pr->Orig :" >#< pp2i p2oi
       >-< "Pr->Facts:" >#< pp2i p2fi
    where pp2i = ppAssocLV . assocLMapElt ppCommaList . Map.toList
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code gen for bindings required by a ProvenGraph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgCxBindLMap :: ProvenGraph -> CxBindLMap
prvgCxBindLMap g@(ProvenGraph i2n _ _ p2fi)
  =  CxBindLMap
     .  Map.fromList
     .  map  (\i -> let dpdS = prvgReachableTo' True g [i]
                    in  (i,[ b | (i,b) <- binds, i `Set.member` dpdS ])
             )
     $  leaveL
  where   factPoiL = concat (Map.elems p2fi)
          leaveL = prvgAllLeaves g
          leaveS = Set.fromList leaveL
          binds  = [ (i,(CBind_Bind (poiHNm i) ev,i,(r `Set.difference` Set.fromList les) `Set.intersection` leaveS))
                   | (i,ProvenAnd _ _ les _ ev) <- Map.toList i2n
                   , not (i `elem` factPoiL)
                   , let (r,_) = prvg2ReachableFrom g [i]
                   ]
%%]

%%[9
prvgIntroBindL :: (PredOccId -> Bool) -> [PredOccId] -> ProvenGraph -> CBindL
prvgIntroBindL poiIsGlob topSort g@(ProvenGraph i2n _ _ _)
  = [ CBind_Bind (poiHNm i) ev
    | (i,ProvenAnd _ _ _ _ ev) <- introNoDpd ++ introGlob, not (isFact i)
    ]
  where  introNoDpd     = [ nn | nn@(i,ProvenAnd _ es les _ _) <- Map.toList i2n, null es, null les ]
         introGlob      = [ (i,n) | i <- Set.toList (prvgSatisfiedNodeS True poiIsGlob g topSort)
                                  , n <- maybeToList (Map.lookup i i2n)
                          ]
         isFact         = prvgIsFact g
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code gen for let holes in a ProvenGraph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgLetHoleCSubst :: ProvenGraph -> PrElimTGam -> CxBindLMap -> CSubst
prvgLetHoleCSubst g@(ProvenGraph i2n _ _ _) peTGam cxBindLM
  = uidCBindLLToCSubst sBinds
  where  sBinds
           = [ (poiId iHole,mkCxBindLForPoiL (availPoiS i iArgs) cxBindLM iArgs)
             | (i,ProvenAnd _ _ (iHole:iArgs) _ _) <- Map.toList i2n
             ]
         availPoiS i iArgs
           = i `Set.delete` (peTGamPoiS (poiCxId i) peTGam `Set.union` Set.fromList iArgs)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Reachable nodes in a ProvenGraph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgReachableFrom :: ProvenGraph -> [PredOccId] -> Set.Set PredOccId
prvgReachableFrom (ProvenGraph i2n _ _ _)
  =  let  r uid reachSet
            =  if uid `Set.member` reachSet
               then  reachSet
               else  let  reachSet' = Set.insert uid reachSet
                     in   case Map.lookup uid i2n of
                                Just (ProvenAnd _ es _ _ _ ) -> rr reachSet' es
                                Just (ProvenOr  _ es _     ) -> rr reachSet' es
                                _                            -> reachSet'
          rr = foldr r
     in   rr Set.empty
%%]

%%[9
prvg2ReachableFrom' :: Bool -> ProvenGraph -> [PredOccId] -> (Set.Set PredOccId,[PredOccId])
prvg2ReachableFrom' hideLamArg (ProvenGraph i2n _ _ _) poiL
  =  let  allPoiS = Set.fromList (Map.keys i2n)
          nextOf poi
            =  case Map.lookup poi i2n of
                  Just (ProvenAnd _ es les _ _ ) -> Set.fromList es `Set.difference` les'
                                                 where les' = if hideLamArg then Set.empty else Set.fromList les
                  Just (ProvenOr  _ es _     )   -> Set.fromList es
                  _                              -> Set.empty
          rr r@(reachSet,revTopSort) poiL
            =  let  newPoiL = Set.toList newPoiS
                    newPoiS = (Set.unions . map nextOf $ poiL) `Set.difference` reachSet
               in   if Set.null newPoiS
                    then r
                    else rr (reachSet `Set.union` newPoiS,newPoiL ++ revTopSort) newPoiL
          (s,l) = rr (Set.fromList poiL,poiL) poiL
     in   (s `Set.intersection` allPoiS,filter (`Set.member` allPoiS) l)
%%]

%%[9
prvg2ReachableFrom :: ProvenGraph -> [PredOccId] -> (Set.Set PredOccId,[PredOccId])
prvg2ReachableFrom = prvg2ReachableFrom' False
%%]

%%[9
prvgReachableTo' :: Bool -> ProvenGraph -> [PredOccId] -> Set.Set PredOccId
prvgReachableTo' hideLamArg (ProvenGraph i2n _ _ _)
  =  let  allNd = Map.elems i2n
          r uid reachSet
            =  if uid `Set.member` reachSet
               then  reachSet
               else  let  reachSet' = Set.insert uid reachSet
                          reachFrom fromNd toUid
                            =  case fromNd of
                                 ProvenAnd _ es les _ _
                                    | hideLamArg
                                        -> inEs && toUid `notElem` les
                                    | otherwise
                                        -> inEs
                                    where inEs = toUid `elem` es
                                 ProvenOr  _ es _
                                    -> toUid `elem` es
                                 _  -> False
                     in   rr reachSet' (Map.keys . Map.filter (\n -> reachFrom n uid) $ i2n)
          rr = foldr r
     in   rr Set.empty
%%]

%%[9
prvgReachableTo :: ProvenGraph -> [PredOccId] -> Set.Set PredOccId
prvgReachableTo = prvgReachableTo' False
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Original nodes, fact nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgOrigs :: ProvenGraph -> [PredOccId]
prvgOrigs (ProvenGraph _ _ p2oi _)
  =  concat (Map.elems p2oi)
%%]

%%[9
prvgFactL :: ProvenGraph -> [PredOccId]
prvgFactL (ProvenGraph _ _ _ p2fi)
  =  concat (Map.elems p2fi)

prvgIsFact :: ProvenGraph -> PredOccId -> Bool
prvgIsFact g = (`elem` prvgFactL g)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Computation along topsort order (bottom to top),
%%% by def each node visited 1x (topsort order should guarantee)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgTopsortCompute
  ::  Ord val =>  (val -> ProvenNode -> Set.Set val -> res -> (Maybe val,Maybe upd)
                  ,PredOccId -> Maybe ProvenNode -> Maybe val
                  ,Set.Set val -> val -> Set.Set val,res -> upd -> res,res
                  )
                  -> ProvenGraph -> [PredOccId] -> res
prvgTopsortCompute (sat,valOf,updDone,updRes,stRes) g@(ProvenGraph i2n _ p2oi _) topSort
  = res
  where  (_,res)
           = foldr  (\poi rd@(done,res)
                        ->  let  mbN = Map.lookup poi i2n
                                 mbPoiVal = valOf poi mbN
                            in   case mbN of
                                   Just n | isJust mbPoiVal && not (poiVal `Set.member` done)
                                       ->  (maybe done (updDone done) mbVal
                                           ,maybe res (updRes res) mbRes
                                           )
                                       where  (mbVal,mbRes) = sat poiVal n done res
                                              poiVal = fromJust mbPoiVal
                                   _   ->  rd
                    )
                    (Set.empty,stRes)
                    topSort
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nodes which do not depend on others
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgAllLeaves :: ProvenGraph -> [PredOccId]
prvgAllLeaves g@(ProvenGraph i2n _ p2oi _)
  = Map.keys (Map.filter isLf i2n) ++ prvgFactL g
  where  isLf (ProvenArg _ _) = True
         isLf _               = False
%%]

%%[9
prvgArgLeaves :: ProvenGraph -> [PredOccId] -> [Pred]
prvgArgLeaves g@(ProvenGraph i2n _ p2oi _) topSort
  =  filter (any (not . tvCatIsFixed) . Map.elems . tyFtvMp . predTy) l
  where  provenAnds pr = [ n | n@(ProvenAnd ndPr _ _ _ _) <- Map.elems i2n, ndPr == pr ]
         l = prvgTopsortCompute (sat,\_ mn -> fmap prvnPred mn,flip Set.insert,flip (:),[]) g topSort
         isFact = prvgIsFact g
         dpdPrsOf (ProvenAnd _ es _ _ _)
           = catMaybes . map (\n -> fmap prvnPred . Map.lookup n $ i2n) . filter (not . isFact) $ es
         sat pr n prDoneS _
           =  case n of
                ProvenAnd _ es _ _ _
                    | not isOrig && needed n
                        ->  (Just pr,Nothing)
                    | not isOrig
                        ->  (Nothing,Nothing)
                _   | isOrig
                        ->  let  ands = provenAnds pr
                            in   if null ands || all (not . needed) ands
                                 then (Just pr,Just pr)
                                 else (Nothing,Nothing)
                    | otherwise
                        ->  (Nothing,Nothing)
           where  isOrig = pr `Map.member` p2oi
                  needed n = any (`Set.member` prDoneS) (dpdPrsOf n)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% All nodes only (indirectly) satisfying a condition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgSatisfiedNodeS :: Bool -> (PredOccId -> Bool) -> ProvenGraph -> [PredOccId] -> Set.Set PredOccId
prvgSatisfiedNodeS hideLamArg satPoi
  =  prvgTopsortCompute (sat,\i _ -> Just i,flip Set.insert,flip Set.insert,Set.empty)
  where  sat poi n _ res
           =  (Just poi,r)
           where  r =  case n of
                         ProvenAnd _ es les _ _
                           | satPoi poi || not (null es)
                                           && all (\i -> i `Set.member` res || satPoi i || hideLamArg && i `elem` les) es
                             ->  Just poi
                         _   ->  Nothing
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Back to orginal nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prvgBackToOrig :: ProvenGraph -> ProvenGraph
prvgBackToOrig g@(ProvenGraph i2n p2i _ p2fi)
  =  let  backL         =  [ (uid,o)  | (p,uidL@(i:is)) <- Map.toList p2i
                                      , let {mo = Map.lookup p p2fi; o = maybe i head mo}
                                      , uid <- maybe is (const uidL) mo
                           ]
          backFM        =  Map.fromList backL
          backUid uid   =  maybe uid id (Map.lookup uid backFM)
          backCSubst    =  poiCExprLToCSubst . assocLMapElt mkCExprPrHole $ backL
          backN n       =  case n of
                             ProvenAnd pr es les c ev    -> ProvenAnd pr (map backUid es) (map backUid les) c (backCSubst `cSubstApp` ev)
                             ProvenOr pr es c            -> ProvenOr pr (map backUid es) c
                             ProvenShare pr e            -> ProvenShare pr (backUid e)
                             _                           -> n
     in   g  { prvgIdNdMp = Map.fromList . map (\(i,n) -> (backUid i,backN n)) . Map.toList $ i2n
             , prvgPrIdMp = Map.mapWithKey (\p l -> maybe l (\(i:_) -> [i]) (Map.lookup p p2fi)) $ p2i
             }
%%]

%%[9
prvgShareMp :: ProvenGraph -> [PredOccId] -> PoiSubst
prvgShareMp g@(ProvenGraph _ p2i p2oi _) topSort
  =  PoiSubst m
  where  (m,_) = prvgTopsortCompute (sat,\i _ -> Just i,flip Set.insert,upd,(Map.empty,Map.empty)) g topSort
         upd (i2i,p2ii) (i1,i2,Just (pr,ii))  = (Map.insert i1 i2 i2i,Map.insert pr (i2,ii) p2ii)
         upd (i2i,p2ii) (i1,i2,Nothing)       = (Map.insert i1 i2 i2i,p2ii)
         sat i n _ res@(i2i,p2ii)
           =  (Just i,r)
           where r =  case n of
                        ProvenArg pr _
                            | isJust mbSh
                                ->  Just (i,shI,Nothing)
                            | otherwise
                                ->  Just (i,i,Just (pr,[]))
                        ProvenAnd pr es _ _ _
                            | null es
                                ->  Just (i,i,Just (pr,[]))
                            | isJust mbSh && shEs == esShL
                                ->  Just (i,shI,Nothing)
                            | otherwise
                                ->  Just (i,i,Just (pr,esShL))
                            where  esShL = map (\i -> maybe i id (Map.lookup i i2i)) es
                        _   ->  Nothing
                   where  mbSh        = Map.lookup (prvnPred n) p2ii
                          (shI,shEs)  = fromJust mbSh
%%]

%%[9
prvg2BackMp :: ProvenGraph -> Map.Map PredOccId PredOccId
prvg2BackMp g@(ProvenGraph i2n p2i p2oi _)
  =  let  isFact         =  prvgIsFact g
          argPoiS        =  Set.fromList [ i | (i,n) <- Map.toList i2n, prvnIsArg n ]
          isArg          =  (`Set.member` argPoiS)
          mkBack b       =  Map.fromList [ (bp,p) | (pr,(p:pL)) <- b, bp <- maybe [] id (Map.lookup pr p2i) ++ pL, not (isFact bp) ]
          backL          =  Map.toList p2oi
          backOrigMp     =  mkBack backL
          backIntermMp   =  mkBack (Map.toList p2i)
     in   backOrigMp `Map.union` backIntermMp
%%]

%%[9
prvgAppPoiSubst :: PoiSubst -> ProvenGraph -> ProvenGraph
prvgAppPoiSubst pois g@(ProvenGraph i2n p2i p2oi p2fi)
  =  let  backPoi       =  (pois `poisApp`)
          backPoiL      =  nub . map backPoi
          backPrFM      =  Map.map backPoiL
          backN n       =  case n of
                             ProvenAnd pr es les c ev    -> ProvenAnd pr (backPoiL es) (backPoiL les) c ev
                             ProvenOr pr es c            -> ProvenOr pr (backPoiL es) c
                             ProvenShare pr e            -> ProvenShare pr (backPoi e)
                             _                           -> n
     in   g  { prvgIdNdMp = Map.fromList . map (\(i,n) -> (backPoi i,backN n)) . Map.toList $ i2n
             , prvgPrIdMp = backPrFM p2i
             , prvgPrOrigIdMp = backPrFM p2oi
             }
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pred resolver, state of prover
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data ProofState
  =  ProofState     { prfs2ProvenGraph        :: ProvenGraph     , prfs2Uniq               :: UID
                    , prfs2PredsToProve       :: [PredOcc]       , prfsId2Depth            :: Map.Map PredOccId Int
                    , prfs2PrElimTGam         :: PrElimTGam      , prfs2ErrL               :: [Err]
                    }

instance Show ProofState where
  show _ = "ProofState"

instance PP ProofState where
  pp s = "PrfSt:" >#<  (pp (prfs2ProvenGraph s)
                       >-< pp (prfs2Uniq s)
                       >-< ppCommaList (prfs2PredsToProve s)
                       )
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Add new preds to prove to proof state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prfsAddPrOccL :: [PredOcc] -> Int -> ProofState -> ProofState
prfsAddPrOccL prOccL depth st
  =  st  { prfs2PredsToProve = prOccL ++ prfs2PredsToProve st
         , prfsId2Depth = Map.fromList [ (poPoi po,depth) | po <- prOccL ] `Map.union` prfsId2Depth st
         }
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functional dependency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data ClsFuncDep = ClsFuncDep [Int] [Int] deriving Show

instance PP ClsFuncDep where
  pp (ClsFuncDep f t) = ppCommaList f >|< "->" >|< ppCommaList t
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Rule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data Rule
  =  Rule
       { rulRuleTy          :: Ty
       , rulMkEvid          :: [CExpr] -> CExpr
       , rulNmEvid          :: HsName
       , rulId              :: PredOccId
       , rulCost            :: ProofCost
       , rulFuncDeps        :: [ClsFuncDep]
       }

emptyRule = Rule Ty_Any head hsnUnknown (mkPrId uidStart uidStart) costVeryMuch []

mkInstElimRule :: HsName -> PredOccId -> Int -> Ty -> Rule
mkInstElimRule n i sz ctxtToInstTy
  =  Rule  { rulRuleTy    = ctxtToInstTy
           , rulMkEvid    = \ctxt -> CExpr_Var n `mkCExprApp` ctxt
           , rulNmEvid    = n
           , rulId        = i
           , rulCost      = costBase `costAdd` (costBase `costMulBy` 2 * sz)
           , rulFuncDeps  = []
           }

instance Substitutable Rule where
  s |=>  r = r { rulRuleTy = s |=> rulRuleTy r }
  ftv    r = ftv (rulRuleTy r)

instance Show Rule where
  show r = show (rulNmEvid r) ++ "::" ++ show (rulRuleTy r)

instance PP Rule where
  pp r = pp (rulRuleTy r) >#< ":>" >#< pp (rulNmEvid r) >|< "/" >|< pp (rulId r) >#< "|" >|< ppCommaList (rulFuncDeps r)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gamma for intro rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data PrIntroGamInfo
  =  PrIntroGamInfo
       { pigiPrToEvidTy     :: Ty
       , pigiKi             :: Ty
       , pigiRule           :: Rule
       } deriving Show

type PrIntroGam     = Gam HsName PrIntroGamInfo

emptyPIGI = PrIntroGamInfo Ty_Any Ty_Any emptyRule

instance PP PrIntroGamInfo where
  pp pigi = pp (pigiRule pigi) >#< "::" >#< ppTy (pigiPrToEvidTy pigi) >#< ":::" >#< ppTy (pigiKi pigi)

instance Substitutable PrIntroGamInfo where
  s |=> pigi        =   pigi { pigiKi = s |=> pigiKi pigi }
  ftv   pigi        =   ftv (pigiKi pigi)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Info for Gamma for elim rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data PrElimGamInfo
  =  PrElimGamInfo
       { pegiRuleL          :: [Rule]
       } deriving Show

instance Substitutable PrElimGamInfo where
  s |=>  pegi = pegi { pegiRuleL = s |=> pegiRuleL pegi }
  ftv    pegi = ftv (pegiRuleL pegi)

instance PP PrElimGamInfo where
  pp pegi = ppCommaList (pegiRuleL pegi)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gamma for elim rules (tgam version)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
type PrElimTGam = TreeGam PrfCtxtId HsName PrElimGamInfo

peTGamAdd :: PrfCtxtId -> HsName -> Rule -> PrElimTGam -> PrElimTGam
peTGamAdd ci n r g
  =  let  (h,mnci,t) = tgamPop ci ci g
          h' = tgamUpdAdd ci n (PrElimGamInfo [r]) (\_ p -> p {pegiRuleL = r : pegiRuleL p}) h
     in   maybe h' (\nci -> tgamPushGam ci nci ci h' t) mnci

peTGamDel :: PrfCtxtId -> HsName -> Rule -> PrElimTGam -> PrElimTGam
peTGamDel ci n r g
  =  maybe g id . tgamMbUpd ci n (\_ p -> p {pegiRuleL = deleteBy (\r1 r2 -> rulId r1 == rulId r2) r . pegiRuleL $ p}) $ g

peTGamAddKnPr :: PrfCtxtId -> HsName -> PredOccId -> Pred -> PrElimTGam -> PrElimTGam
peTGamAddKnPr ci n i p
  = peTGamAdd ci (predMatchNm p) (mkInstElimRule n i 0 (mkTyPr p))

peTGamAddKnPrL :: PrfCtxtId -> UID -> [Pred] -> PrElimTGam -> (PrElimTGam,[HsName],[PredOccId])
peTGamAddKnPrL ci i prL g
  =  foldr  (\(i,p) (g,nL,idL) -> let n = poiHNm i in (peTGamAddKnPr ci n i p g,n:nL,i:idL))
            (g,[],[])
            (zip (map (mkPrId ci) . mkNewUIDL (length prL) $ i) prL)

peTGamPoiS :: PrfCtxtId -> PrElimTGam -> Set.Set PredOccId
peTGamPoiS ci = Set.unions . map (Set.fromList . map rulId . pegiRuleL) . tgamElts ci
%%]


