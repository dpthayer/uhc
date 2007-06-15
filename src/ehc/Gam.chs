%%[0
%include lhs2TeX.fmt
%include afp.fmt
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gamma (aka Assumptions, Environment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1 module {%{EH}Gam} import(Data.List,EH.Util.Utils,{%{EH}Base.Builtin},{%{EH}Base.Common},{%{EH}NameAspect}) export(Gam,emptyGam,gamMap,gamLookup,gamLookupDup, gamPushNew, gamPop, gamTop, gamAddGam, gamAdd, gamPushGam, gamToAssocL, gamToAssocDupL, assocLToGam, assocDupLToGam,gamKeys)
%%]

%%[1 import({%{EH}Ty},{%{EH}Error}) export(ValGam, ValGamInfo(..), valGamLookup,valGamLookupTy)
%%]

%%[1 export(TyGam, TyGamInfo(..), tyGamLookup, initTyGam)
%%]

%%[1 export(FixityGam, FixityGamInfo(..), defaultFixityGamInfo)
%%]

%%[1 import(EH.Util.Pretty,{%{EH}Ty.Pretty}) export(ppGam,ppGamDup)
%%]

%%[1 export(gamSingleton,gamInsert,gamUnion,gamUnions,gamFromAssocL)
%%]

%%[1 export(IdDefOccGam,IdDefOccAsc)
%%]

%%[2 import({%{EH}VarMp},{%{EH}Substitutable})
%%]

%%[3 import({%{EH}Ty.Trf.Quantify}) export(valGamQuantify,gamMapElts,valGamMapTy)
%%]

%%[3 export(gamPartition)
%%]

%%[4 import({%{EH}Base.Opts},{%{EH}Ty.Trf.Instantiate}) export(valGamInst1Exists)
%%]

%%[4 import({%{EH}Ty.FitsInCommon})
%%]

%%[4 export(gamMapThr)
%%]

%%[4_2 export(ErrGam)
%%]

%%[4_2 export(valGamQuantifyWithVarMp,valGamInst1ExistsWithVarMp)
%%]

%%[6 export(gamUnzip)
%%]

%%[6 export(KiGam, KiGamInfo(..),initKiGam)
%%]

%%[6 export(mkTGI,mkTGIData)
%%]

%%[7 import(Data.Maybe,qualified Data.Set as Set,qualified Data.Map as Map) export(gamNoDups)
%%]

%%[8 import({%{EH}Core})
%%]

%%[9 import({%{EH}Base.Debug},{%{EH}Core.Subst},{%{EH}Ty.FitsInCommon}) export(gamElts)
%%]

%%[9 import({%{EH}Ty.Trf.MergePreds})
%%]

%%[9 export(idDefOccGamPartitionByKind)
%%]

%%[20 export(idDefOccGamByKind)
%%]

%%[99 import({%{EH}Base.ForceEval},{%{EH}Ty.Trf.ForceEval})
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.Base.type
newtype Gam k v     =   Gam [AssocL k v]  deriving Show
%%]

%%[9.Base.type -1.Base.type
type Gam k v        =   LGam k v
%%]
type Gam k v        =   TreeGam Int k v

%%[1.Base.sigs
emptyGam            ::            Gam k v
gamSingleton        ::            k -> v        -> Gam k v
gamLookup           ::  Ord k =>  k -> Gam k v  -> Maybe v
gamToAssocL         ::            Gam k v       -> AssocL k v
gamPushNew          ::            Gam k v       -> Gam k v
gamPushGam          ::  Ord k =>  Gam k v       -> Gam k v -> Gam k v
gamPop              ::  Ord k =>  Gam k v       -> (Gam k v,Gam k v)
gamAddGam           ::  Ord k =>  Gam k v       -> Gam k v -> Gam k v
gamAdd              ::  Ord k =>  k -> v        -> Gam k v -> Gam k v
%%]

%%[1.Base.funs
emptyGam                            = Gam [[]]
gamSingleton    k v                 = Gam [[(k,v)]]
gamLookup       k (Gam ll)          = foldr  (\l mv -> maybe mv Just (lookup k l))
                                             Nothing ll
gamToAssocL     (Gam ll)            = concat ll
gamPushNew      (Gam ll)            = Gam ([]:ll)
gamPushGam      g1 (Gam ll2)        = Gam (gamToAssocL g1 : ll2)
gamPop          (Gam (l:ll))        = (Gam [l],Gam ll)
gamAddGam       g1 (Gam (l2:ll2))   = Gam ((gamToAssocL g1 ++ l2):ll2)
gamAdd          k v g               = gamAddGam (k `gamSingleton` v) g
%%]

%%[9.Base.funs -1.Base.funs
emptyGam                            = emptyLGam
gamSingleton                        = lgamSingleton
gamLookup       k g                 = lgamLookup k g
gamToAssocL     g                   = lgamToAssocL g
gamPushNew      g                   = lgamPushNew g
gamPushGam      g1 g2               = lgamPushGam g1 g2
gamPop          g                   = lgamPop g
gamAddGam       g1 g2               = lgamUnion g1 g2
gamAdd          k v g               = lgamUnion (lgamSingleton k v) g
%%]

%%[1.Rest.sigs
gamTop              ::  Ord k =>  Gam k v     -> Gam k v
assocLToGam         ::  Ord k =>  AssocL k v  -> Gam k v
%%]

%%[1.Rest.funs
gamTop                              = fst . gamPop
assocLToGam     l                   = Gam [l]
%%]

%%[9.Rest.funs -1.Rest.funs
gamTop                              = lgamTop
assocLToGam                         = lgamFromAssocL
%%]

%%[1.assocDupLToGam
assocDupLToGam :: Ord k => AssocL k [v] -> Gam k v
assocDupLToGam = assocLToGam . concat . map (\(k,vs) -> zip (repeat k) vs)
%%]

%%[9 -1.assocDupLToGam
assocDupLToGam :: Ord k => AssocL k [v] -> Gam k v
assocDupLToGam = lgamFromAssocDupL
%%]

%%[1.gamToAssocDupL
gamToAssocDupL :: Ord k => Gam k v -> AssocL k [v]
gamToAssocDupL = map (foldr (\(k,v) (_,vs) -> (k,v:vs)) (undefined,[])) . groupSortOn fst . gamToAssocL
%%]

%%[9 -1.gamToAssocDupL
gamToAssocDupL :: Ord k => Gam k v -> AssocL k [v]
gamToAssocDupL g = lgamToAssocDupL g
%%]

%%[1.gamToOnlyDups export(gamToOnlyDups)
gamToOnlyDups :: Ord k => Gam k v -> AssocL k [v]
gamToOnlyDups g = [ x | x@(n,(_:_:_)) <- gamToAssocDupL g ]
%%]

%%[1.gamNoDups
gamNoDups :: Ord k => Gam k v -> Gam k v
gamNoDups (Gam ll) = Gam (map (nubBy (\(k1,_) (k2,_) -> k1 == k2)) ll)
%%]

%%[9 -1.gamNoDups
gamNoDups :: Ord k => Gam k v -> Gam k v
gamNoDups g = lgamNoDups g
%%]

%%[1.gamMap
gamMap :: ((k,v) -> (k',v')) -> Gam k v -> Gam k' v'
gamMap f (Gam ll) = Gam (map (map f) ll)
%%]

%%[9.gamMap -1.gamMap
gamMap :: (Ord k,Ord k') => ((k,v) -> (k',v')) -> Gam k v -> Gam k' v'
gamMap f g = lgamMapEltWithKey (\k e -> let (k',v') = f (k,lgeVal e) in (k',e {lgeVal = v'})) g
%%]

%%[3.gamMapElts
gamMapElts :: Ord k => (v -> v') -> Gam k v -> Gam k v'
gamMapElts f = gamMap (\(n,v) -> (n,f v))
%%]

%%[3.gamPartition
gamPartition :: (k -> v -> Bool) -> Gam k v -> (Gam k v,Gam k v)
gamPartition f (Gam ll)
  = (Gam ll1,Gam ll2)
  where (ll1,ll2)
           = unzip $ map (partition (\(k,v) -> f k v)) $ ll
%%]

%%[9 -3.gamPartition
gamPartition :: Ord k => (k -> v -> Bool) -> Gam k v -> (Gam k v,Gam k v)
gamPartition = lgamPartitionWithKey
%%]

%%[4.gamMapThr
gamMapThr :: ((k,v) -> t -> ((k',v'),t)) -> t -> Gam k v -> (Gam k' v',t)
gamMapThr f thr (Gam ll)
  =  let (ll',thr')
           =  (foldr  (\l (ll,thr)
                        ->  let  (l',thr')
                                    =  foldr  (\kv (l,thr)
                                                ->  let (kv',thr') = f kv thr in (kv':l,thr')
                                              ) ([],thr) l
                            in   (l':ll,thr')
                      ) ([],thr) ll
              )
     in  (Gam ll',thr')
%%]

%%[9.gamMapThr -4.gamMapThr
gamMapThr :: (Ord k,Ord k') => ((k,v) -> t -> ((k',v'),t)) -> t -> Gam k v -> (Gam k' v',t)
gamMapThr f thr g = lgamFilterMapEltAccumWithKey (\_ _ -> True) (\k e thr -> let ((k',v'),thr') = f (k,lgeVal e) thr in (k',e {lgeVal = v'},thr')) undefined thr g
%%]

%%[1
gamKeys :: Ord k => Gam k v -> [k]
gamKeys = assocLKeys . gamToAssocL
%%]

%%[9
gamElts :: Ord k => Gam k v -> [v]
gamElts = assocLElts . gamToAssocL
%%]

%%[1.gamLookupDup
gamLookupDup :: Ord k => k -> Gam k v -> Maybe [v]
gamLookupDup k (Gam ll) = foldr (\l mv -> case filter ((==k) . fst) l of {[] -> mv; lf -> Just (assocLElts lf)}) Nothing ll
%%]

%%[9 -1.gamLookupDup
gamLookupDup :: Ord k => k -> Gam k v -> Maybe [v]
gamLookupDup k g = lgamLookupDup k g
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Aliases, for future compliance with naming conventions of (e.g.) Data.Map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1
gamInsert :: Ord k => k -> v -> Gam k v -> Gam k v
gamInsert = gamAdd

gamUnion :: Ord k => Gam k v -> Gam k v -> Gam k v
gamUnion = gamAddGam

gamUnions :: Ord k => [Gam k v] -> Gam k v
gamUnions = foldr1 gamUnion

gamFromAssocL ::  Ord k =>  AssocL k v  -> Gam k v
gamFromAssocL = assocLToGam
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Level Gam, a Gam with entries having a level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
data LGamElt v
  = LGamElt
      { lgeLev		:: !Int
      , lgeVal		:: !v
      }

data LGam k v
  = LGam
      { lgLev		:: !Int
      , lgMap		:: Map.Map k [LGamElt v]		-- strictness has negative mem usage effect. Why??
      }

emptyLGam :: LGam k v
emptyLGam = LGam 0 Map.empty

instance Show (LGam k v) where
  show _ = "LGam"
%%]

%%[9
lgamFilterMapEltAccumWithKey
  :: (Ord k')
       => (k -> LGamElt v -> Bool)
          -> (k -> LGamElt v -> acc -> (k',LGamElt v',acc))
          -> (k -> LGamElt v -> acc -> acc)
          -> acc -> LGam k v -> (LGam k' v',acc)
lgamFilterMapEltAccumWithKey p fyes fno a g
  = (g {lgMap = m'},a')
  where (m',a') = Map.foldWithKey
                    (\k es ma@(m,a)
                      -> foldr (\e (m,a)
                                 -> if p k e
                                    then let (k',e',a') = fyes k e a
                                         in  (Map.insertWith (++) k' [e'] m,a')
                                    else (m,fno k e a)
                               ) ma es
                    ) (Map.empty,a) (lgMap g)
%%]

%%[9
lgamSingleton :: k -> v -> LGam k v
lgamSingleton k v = LGam 0 (Map.singleton k [LGamElt 0 v])

lgamUnion :: Ord k => LGam k v -> LGam k v -> LGam k v
lgamUnion g1@(LGam {lgMap = m1}) g2@(LGam {lgLev = l2, lgMap = m2})
  = g2 {lgMap = Map.unionWith (++) m1' m2}
  -- where m1' = Map.map (\(e:_) -> [e {lgeLev = l2}]) $ Map.filter (\es -> not (null es)) m1
  where m1' = Map.map (map (\e -> e {lgeLev = l2})) $ Map.filter (\es -> not (null es)) m1

lgamUnions :: Ord k => [LGam k v] -> LGam k v
lgamUnions [] = emptyLGam
lgamUnions l  = foldr1 lgamUnion l

lgamPartitionEltWithKey :: Ord k => (k -> LGamElt v -> Bool) -> LGam k v -> (LGam k v,LGam k v)
lgamPartitionEltWithKey p g
  = (g1, LGam (lgLev g1) m2)
  where (g1,m2) = lgamFilterMapEltAccumWithKey p (\k e a -> (k,e,a)) (\k e a -> Map.insertWith (++) k [e] a) Map.empty g

lgamPartitionWithKey :: Ord k => (k -> v -> Bool) -> LGam k v -> (LGam k v,LGam k v)
lgamPartitionWithKey p = lgamPartitionEltWithKey (\k e -> p k (lgeVal e))

lgamUnzip :: Ord k => LGam k (v1,v2) -> (LGam k v1,LGam k v2)
lgamUnzip g
  = (g1, g1 {lgMap = m2})
  where (g1,m2) = lgamFilterMapEltAccumWithKey (\_ _ -> True) (\k e@(LGamElt {lgeVal = (v1,v2)}) m -> (k,e {lgeVal = v1},Map.insertWith (++) k [e {lgeVal = v2}] m)) undefined Map.empty g

lgamMapEltWithKey :: (Ord k,Ord k') => (k -> LGamElt v -> (k',LGamElt v')) -> LGam k v -> LGam k' v'
lgamMapEltWithKey f g
  = g'
  where (g',_) = lgamFilterMapEltAccumWithKey (\_ _ -> True) (\k e a -> let (k',e') = f k e in (k',e',a)) undefined () g

lgamPop :: Ord k => LGam k v -> (LGam k v,LGam k v)
lgamPop g@(LGam {lgMap = m, lgLev = l})
  = (LGam 0 $ mk ts, LGam (max 0 (l-1)) $ mk rs)
  where (ts,rs) = unzip [ ((k,t),(k,r)) | (k,es) <- Map.toList m, let (t,r) = span (\e -> l <= lgeLev e) es ]
        mk = Map.filter (not . null) . Map.fromList
{-
lgamPop :: Ord k => LGam k v -> (LGam k v,LGam k v)
lgamPop g
  = (lgamMapEltWithKey (\k e -> (k,e {lgeLev = 0})) (g1 {lgLev = 0}),g2 {lgLev = max 0 (lgLev g - 1)})
  where (g1,g2) = lgamPartitionEltWithKey (\_ e -> lgeLev e == lgLev g) g
-}

-- gamTop = fst . gamPop
lgamTop :: Ord k => LGam k v -> LGam k v
lgamTop g@(LGam {lgMap = m, lgLev = l})
  = LGam 0 $ Map.fromList [ (k,t) | (k,es) <- Map.toList m, let t = takeWhile (\e -> l <= lgeLev e) es, not (null t) ]

lgamPushNew :: LGam k v -> LGam k v
lgamPushNew g = g {lgLev = lgLev g + 1}

lgamPushGam :: Ord k => LGam k v -> LGam k v -> LGam k v
lgamPushGam g1 g2 = lgamUnions [g1,lgamPushNew g2]

lgamLookupDup :: Ord k => k -> LGam k v -> Maybe [v]
lgamLookupDup k = fmap (map lgeVal) . Map.lookup k . lgMap

lgamLookup :: Ord k => k -> LGam k v -> Maybe v
lgamLookup k = fmap head . lgamLookupDup k

lgamToAssocDupL :: LGam k v -> AssocL k [v]
lgamToAssocDupL = Map.toList . Map.map (map lgeVal) . lgMap

lgamToAssocL :: LGam k v -> AssocL k v
lgamToAssocL g = [ (k,v) | (k,(v:_)) <- lgamToAssocDupL g ]

lgamFromAssocDupL :: Ord k => AssocL k [v] -> LGam k v
lgamFromAssocDupL l
  = LGam 0 m
  where m = Map.map (map (LGamElt 0)) $ Map.fromList l

lgamFromAssocL :: Ord k => AssocL k v -> LGam k v
lgamFromAssocL = lgamUnions . map (uncurry lgamSingleton)

lgamNoDups :: LGam k v -> LGam k v
lgamNoDups g
  = g {lgMap = m}
  where m = Map.map (\(e:_) -> [e]) $ lgMap g
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Error" gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4_2
type ErrGam = Gam HsName ErrL
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fixity gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1
data FixityGamInfo = FixityGamInfo { fgiPrio :: !Int, fgiFixity :: !Fixity } deriving Show

defaultFixityGamInfo = FixityGamInfo fixityMaxPrio Fixity_Infixl
%%]

%%[1.FixityGam
type FixityGam = Gam HsName FixityGamInfo
%%]

%%[1 export(fixityGamLookup)
fixityGamLookup :: HsName -> FixityGam -> FixityGamInfo
fixityGamLookup nm fg = maybe defaultFixityGamInfo id $ gamLookup nm fg
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Type of value" gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.ValGam.Base
data ValGamInfo
  = ValGamInfo { vgiTy :: Ty }		-- strictness has negative mem usage effect. Why??
  deriving Show

type ValGam = Gam HsName ValGamInfo
%%]

%%[1.valGamLookup
valGamLookup :: HsName -> ValGam -> Maybe ValGamInfo
valGamLookup = gamLookup
%%]

%%[1.valGamLookupTy
valGamLookupTy :: HsName -> ValGam -> (Ty,ErrL)
valGamLookupTy n g
  =  case valGamLookup n g of
       Nothing    ->  (Ty_Any,[rngLift emptyRange mkErr_NamesNotIntrod "value" [n]])
       Just vgi   ->  (vgiTy vgi,[])
%%]

%%[4.valGamLookup -1.valGamLookup
valGamLookup :: HsName -> ValGam -> Maybe ValGamInfo
valGamLookup nm g
  =  case gamLookup nm g of
       Nothing
         |  hsnIsProd nm
                 -> let pr = mkPr nm in mkRes (tyProdArgs pr `mkArrow` pr)
         |  hsnIsUn nm && hsnIsProd (hsnUnUn nm)
                 -> let pr = mkPr (hsnUnUn nm) in mkRes ([pr] `mkArrow` pr)
         where  mkPr nm  = mkTyFreshProd (hsnProdArity nm)
                mkRes t  = Just (ValGamInfo (tyQuantifyClosed t))
       Just vgi  -> Just vgi
       _         -> Nothing
%%]

%%[3.valGamMapTy
valGamMapTy :: (Ty -> Ty) -> ValGam -> ValGam
valGamMapTy f = gamMapElts (\vgi -> vgi {vgiTy = f (vgiTy vgi)})
%%]

%%[3.valGamQuantify
valGamQuantify :: TyVarIdL -> ValGam -> ValGam
valGamQuantify globTvL = valGamMapTy (\t -> tyQuantify (`elem` globTvL) t)
%%]

%%[4_2.valGamDoWithVarMp
valGamDoWithVarMp :: (Ty -> thr -> (Ty,thr)) -> VarMp -> thr -> ValGam -> (ValGam,VarMp)
valGamDoWithVarMp f gamVarMp thr gam
  =  let  (g,(_,c))
            =  gamMapThr
                    (\(n,vgi) (thr,c)
                        ->  let  t = vgiTy vgi
                                 (t',thr') = f (gamVarMp |=> t) thr
                                 (tg,cg) =  case t of
                                                Ty_Var v _ -> (t,v `varmpTyUnit` t')
                                                _ -> (t',emptyVarMp)
                            in   ((n,vgi {vgiTy = tg}),(thr',cg `varmpPlus` c))
                    )
                    (thr,emptyVarMp) gam
     in   (g,c)
%%]

%%[4_2.valGamQuantifyWithVarMp
valGamQuantifyWithVarMp :: VarMp -> TyVarIdL -> ValGam -> (ValGam,VarMp)
valGamQuantifyWithVarMp = valGamDoWithVarMp (\t globTvL -> (tyQuantify (`elem` globTvL) t,globTvL))
%%]

%%[6.gamUnzip
gamUnzip :: Gam k (v1,v2) -> (Gam k v1,Gam k v2)
gamUnzip (Gam ll)
  =  let  (ll1,ll2) = unzip . map (unzip . map (\(n,(v1,v2)) -> ((n,v1),(n,v2)))) $ ll
     in   (Gam ll1,Gam ll2)
%%]

%%[9.gamUnzip -6.gamUnzip
gamUnzip :: Ord k => Gam k (v1,v2) -> (Gam k v1,Gam k v2)
gamUnzip g = lgamUnzip g
%%]

%%[9.valGamQuantify -3.valGamQuantify
valGamQuantify :: TyVarIdL -> [PredOcc] -> ValGam -> (ValGam,Gam HsName TyMergePredOut)
valGamQuantify globTvL prL g
  =  let  g' = gamMapElts  (\vgi ->  let  tmpo = tyMergePreds prL (vgiTy vgi)
                                          ty   = tyQuantify (`elem` globTvL) (tmpoTy tmpo)
                                     in   (vgi {vgiTy = ty},tmpo {tmpoTy = ty})
                           ) g
     in   gamUnzip g'
%%]

%%[4.valGamInst1Exists
gamInst1Exists :: Ord k => (v -> Ty,v -> Ty -> v) -> UID -> Gam k v -> Gam k v
gamInst1Exists (extr,upd) u
  =  fst . gamMapThr (\(n,t) u -> let (u',ue) = mkNewLevUID u in ((n,upd t (tyInst1Exists ue (extr t))),u')) u

valGamInst1Exists :: UID -> ValGam -> ValGam
valGamInst1Exists = gamInst1Exists (vgiTy,(\vgi t -> vgi {vgiTy=t}))
%%]

%%[66_4.valGamCloseExists
valGamCloseExists :: ValGam -> ValGam
valGamCloseExists = valGamMapTy (\t -> tyQuantify (not . tvIsEx (tyFtvMp t)) t)
%%]

%%[4_2.valGamInst1ExistsWithVarMp
valGamInst1ExistsWithVarMp :: VarMp -> UID -> ValGam -> (ValGam,VarMp)
valGamInst1ExistsWithVarMp
  =  valGamDoWithVarMp
        (\t u ->  let  (u',ue) = mkNewLevUID u
                  in   (tyInst1Exists ue t,u')
        )
%%]

%%[7 export(valGamTyOfDataCon)
valGamTyOfDataCon :: HsName -> ValGam -> (Ty,Ty,ErrL)
valGamTyOfDataCon conNm g
  = (t,rt,e)
  where (t,e) = valGamLookupTy conNm g
        (_,rt) = tyArrowArgsRes t
%%]

%%[7 export(valGamTyOfDataFld)
valGamTyOfDataFld :: HsName -> ValGam -> (Ty,Ty,ErrL)
valGamTyOfDataFld fldNm g
  | null e    = (t,rt,e)
  | otherwise = (t,Ty_Any,e)
  where (t,e) = valGamLookupTy fldNm g
        ((rt:_),_) = tyArrowArgsRes t
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Type of type" and "Kind of type" gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.TyGamInfo
data TyGamInfo = TyGamInfo { tgiTy :: !Ty } deriving Show
%%]

%%[6.mkTGIData
mkTGIData :: Ty -> Ty -> TyGamInfo
mkTGIData t _ = TyGamInfo t
%%]

%%[6
mkTGI :: Ty -> TyGamInfo
mkTGI t = mkTGIData t Ty_Any
%%]

%%[1.emtpyTGI export(emtpyTGI)
emtpyTGI :: TyGamInfo
emtpyTGI = TyGamInfo Ty_Any
%%]

%%[1.TyGam
type TyGam = Gam HsName TyGamInfo
%%]

%%[1.tyGamLookup
tyGamLookup :: HsName -> TyGam -> Maybe TyGamInfo
tyGamLookup nm g
  =  case gamLookup nm g of
       Nothing | hsnIsProd nm   -> Just (TyGamInfo (Ty_Con nm))
       Just tgi                 -> Just tgi
       _                        -> Nothing
%%]

%%[1 export(tyGamLookupErr)
tyGamLookupErr :: HsName -> TyGam -> (TyGamInfo,ErrL)
tyGamLookupErr n g
  = case tyGamLookup n g of
      Nothing  -> (emtpyTGI,[rngLift emptyRange mkErr_NamesNotIntrod "type" [n]])
      Just tgi -> (tgi,[])
%%]

%%[6.tyGamLookup -1.tyGamLookup
tyGamLookup :: HsName -> TyGam -> Maybe TyGamInfo
tyGamLookup nm g
  =  case gamLookup nm g of
       Nothing
         |  hsnIsProd nm
                 -> Just (TyGamInfo (Ty_Con nm))
       Just tgi  -> Just tgi
       _         -> Nothing
%%]

%%[7.tyGamLookup -6.tyGamLookup
tyGamLookup :: HsName -> TyGam -> Maybe TyGamInfo
tyGamLookup = gamLookup
%%]

%%[6 export(tyKiGamQuantify)
tyKiGamQuantify :: TyVarIdL -> TyKiGam -> TyKiGam
tyKiGamQuantify globTvL
  = gamMap (\(n,k) -> (n,k {tkgiKi = kiQuantify (`elem` globTvL) (tkgiKi k)}))
%%]

%%[6 export(tyKiGamInst1Exists)
tyKiGamInst1Exists :: UID -> TyKiGam -> TyKiGam
tyKiGamInst1Exists = gamInst1Exists (tkgiKi,(\i k -> i {tkgiKi=k}))
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Kind of type variable/name" gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[6 export(TyKiGamInfo(..),TyKiGam,emptyTKGI)
data TyKiGamInfo = TyKiGamInfo { tkgiKi :: !Ty } deriving Show

emptyTKGI :: TyKiGamInfo
emptyTKGI = TyKiGamInfo kiStar

type TyKiGam = Gam TyKiKey TyKiGamInfo
%%]

%%[6 export(tyKiGamLookup,tyKiGamLookupByName)
tyKiGamLookupByName :: HsName -> TyKiGam -> Maybe TyKiGamInfo
tyKiGamLookupByName n g = gamLookup (TyKiKey_Name n) g

tyKiGamLookup :: Ty -> TyKiGam -> Maybe TyKiGamInfo
tyKiGamLookup t g
  = case tyMbVar t of
      Just v  -> gamLookup (TyKiKey_TyVar v) g
      Nothing -> case tyMbCon t of
                   Just n -> tyKiGamLookupByName n g
                   _      -> Nothing
%%]

%%[6 export(tyKiGamLookupErr,tyKiGamLookupByNameErr)
tyKiGamLookupErr :: Ty -> TyKiGam -> (TyKiGamInfo,ErrL)
tyKiGamLookupErr t g
  = case tyKiGamLookup t g of
      Nothing -> (emptyTKGI,[rngLift emptyRange mkErr_NamesNotIntrod "kind" [mkHNm $ show t]])
      Just i  -> (i,[])

tyKiGamLookupByNameErr :: HsName -> TyKiGam -> (TyKiGamInfo,ErrL)
tyKiGamLookupByNameErr n g = tyKiGamLookupErr (semCon n) g
%%]

%%[6 export(tyKiGamNameSingleton,tyKiGamSingleton,tyKiGamVarSingleton)
tyKiGamNameSingleton :: HsName -> TyKiGamInfo -> TyKiGam
tyKiGamNameSingleton n k = gamSingleton (TyKiKey_Name n) k

tyKiGamVarSingleton :: TyVarId -> TyKiGamInfo -> TyKiGam
tyKiGamVarSingleton v k = gamSingleton (TyKiKey_TyVar v) k

tyKiGamSingleton :: Ty -> TyKiGamInfo -> TyKiGam
tyKiGamSingleton t k
  = case tyMbVar t of
      Just v  -> tyKiGamVarSingleton v k
      Nothing -> case tyMbCon t of
                   Just n -> tyKiGamNameSingleton n k
                   _      -> panic "Gam.tyKiGamSingleton"
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Data tag/etc info gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[7 export(DataFldMp,DataFldInfo(..),emptyDataFldInfo)
data DataFldInfo
  = DataFldInfo
%%[[8
      { dfiOffset 	:: !Int
      }
%%]]
      deriving Show

type DataFldMp = Map.Map HsName DataFldInfo

emptyDataFldInfo
  = DataFldInfo
%%[[8
      (-1)
%%]]
%%]

%%[7 export(DataTagInfo(..),emptyDataTagInfo,DataConstrTagMp)
data DataTagInfo
  = DataTagInfo
      { dtiFldMp    		:: !DataFldMp
      , dtiConNm			:: !HsName
%%[[8
      , dtiCTag 			:: !CTag
%%]]
%%[[95
      , dtiMbFixityPrio 	:: !(Maybe Int)
%%]]
      } deriving Show

type DataConstrTagMp = Map.Map HsName DataTagInfo

emptyDataTagInfo
  = DataTagInfo
      Map.empty hsnUnknown
%%[[8
      emptyCTag
%%]]
%%[[95
      Nothing
%%]]
%%]

%%[8 export(dtiOffsetOfFld)
dtiOffsetOfFld :: HsName -> DataTagInfo -> Int
dtiOffsetOfFld fldNm dti = dfiOffset $ panicJust "dtiOffsetOfFld" $ Map.lookup fldNm $ dtiFldMp dti
%%]

%%[8 export(DataFldInConstr(..),DataFldInConstrMp)
data DataFldInConstr
  = DataFldInConstr
      { dficInTagMp	:: !(Map.Map CTag Int)
      }

type DataFldInConstrMp = Map.Map HsName DataFldInConstr
%%]

%%[7 export(DataGam,DataGamInfo(..),mkDGI)
data DataGamInfo
  = DataGamInfo
      { dgiTyNm      		:: !HsName
      , dgiDataTy 			:: !Ty
%%[[20
      , dgiConstrNmL 		:: ![HsName]
%%]]
      , dgiConstrTagMp 		:: !DataConstrTagMp
%%[[8
      , dgiFldInConstrMp	:: !DataFldInConstrMp
      , dgiIsNewtype 		:: !Bool
%%]]
      }

type DataGam = Gam HsName DataGamInfo

instance Show DataGamInfo where
  show _ = "DataGamInfo"

mkDGI :: HsName -> Ty -> [HsName] -> DataConstrTagMp -> Bool -> DataGamInfo
mkDGI tyNm dty cNmL m nt
  = DataGamInfo
      tyNm dty
%%[[20
      cNmL
%%]]
      m
%%[[8
      fm nt
  where fm = Map.map DataFldInConstr $ Map.unionsWith Map.union
             $ [ Map.singleton f (Map.singleton (dtiCTag ci) (dfiOffset fi)) | ci <- Map.elems m, (f,fi) <- Map.toList $ dtiFldMp ci ]
%%]]
%%]

%%[7 export(emptyDataGamInfo,emptyDGI)
emptyDataGamInfo, emptyDGI :: DataGamInfo
emptyDataGamInfo = mkDGI hsnUnknown Ty_Any [] Map.empty False
emptyDGI = emptyDataGamInfo
%%]

%%[20 export(dgiConstrTagAssocL)
dgiConstrTagAssocL :: DataGamInfo -> AssocL HsName DataTagInfo
dgiConstrTagAssocL dgi = [ (cn,panicJust "dgiConstrTagAssocL" $ Map.lookup cn $ dgiConstrTagMp dgi) | cn <- dgiConstrNmL dgi ]
%%]

%%[7 export(dgiDtiOfCon)
dgiDtiOfCon :: HsName -> DataGamInfo -> DataTagInfo
dgiDtiOfCon conNm dgi = panicJust "dgiDtiOfCon" $ Map.lookup conNm $ dgiConstrTagMp dgi
%%]

%%[7 export(dataGamLookup,dataGamLookupErr)
dataGamLookup :: HsName -> DataGam -> Maybe DataGamInfo
dataGamLookup nm g
  =  case gamLookup nm g of
       Nothing
         |  hsnIsProd nm							-- ??? should not be necessary, in variant 7 where tuples are represented by records
                 -> Just emptyDataGamInfo
       Just dgi  -> Just dgi
       _         -> Nothing

dataGamLookupErr :: HsName -> DataGam -> (DataGamInfo,ErrL)
dataGamLookupErr n g
  = case dataGamLookup n g of
      Nothing  -> (emptyDGI,[rngLift emptyRange mkErr_NamesNotIntrod "data" [n]])
      Just tgi -> (tgi,[])
%%]

%%[7 export(dataGamDgiOfTy)
dataGamDgiOfTy :: Ty -> DataGam -> Maybe DataGamInfo
dataGamDgiOfTy conTy dg = dataGamLookup (tyAppFunConNm conTy) dg
%%]

%%[8 export(dataGamDTIsOfTy)
dataGamDTIsOfTy :: Ty -> DataGam -> Maybe [DataTagInfo]
dataGamDTIsOfTy t g
  = fmap
%%[[8
      (Map.elems . dgiConstrTagMp)
%%][95
      (assocLElts . dgiConstrTagAssocL)
%%]]
    $ gamLookup (tyAppFunConNm t)
    $ g
%%]

%%[8 export(dataGamTagsOfTy)
dataGamTagsOfTy :: Ty -> DataGam -> Maybe [CTag]
dataGamTagsOfTy t g
  = fmap (map dtiCTag) (dataGamDTIsOfTy t g)
%%]

Lookup by constructor name:

%%[8
%%]
valDataGamLookup :: HsName -> ValGam -> DataGam -> Maybe DataGamInfo
valDataGamLookup nm vg dg
  = do { vgi <- valGamLookup nm vg
       ; dgi <- dataGamDgiOfTy (vgiTy vgi) dg
       }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Ty app spine" gam, to be merged with tyGam in the future
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.AppSpineGam export(AppSpineGam, asGamLookup)
type AppSpineGam = Gam HsName AppSpineInfo

asGamLookup :: HsName -> AppSpineGam -> Maybe AppSpineInfo
asGamLookup nm g
  = case gamLookup nm g of
      j@(Just _)             -> j
      Nothing | hsnIsProd nm -> Just $ emptyAppSpineInfo {asgiVertebraeL = take (hsnProdArity nm) prodAppSpineVertebraeInfoL}
      _                      -> Nothing

%%]

%%[4.appSpineGam export(appSpineGam)
appSpineGam :: AppSpineGam
appSpineGam =  assocLToGam [(hsnArrow, emptyAppSpineInfo {asgiVertebraeL = arrowAppSpineVertebraeInfoL})]
%%]

%%[7.appSpineGam -4.appSpineGam export(appSpineGam)
appSpineGam :: AppSpineGam
appSpineGam
  = assocLToGam
      [ (hsnArrow,    emptyAppSpineInfo {asgiVertebraeL = arrowAppSpineVertebraeInfoL})
      , (hsnRec,      emptyAppSpineInfo {asgiVertebraeL = take 1 prodAppSpineVertebraeInfoL})
      ]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "Sort of kind" gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[6
data KiGamInfo = KiGamInfo { kgiKi :: Ty } deriving Show

type KiGam = Gam HsName KiGamInfo
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Identifier definition occurrence gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1
type IdDefOccGam = Gam    IdOcc  IdDefOcc
type IdDefOccAsc = AssocL IdOcc [IdDefOcc]
%%]

%%[9
idDefOccGamPartitionByKind :: [IdOccKind] -> IdDefOccGam -> (IdDefOccAsc,IdDefOccAsc)
idDefOccGamPartitionByKind ks
  = partition (\(IdOcc n k',_) -> k' `elem` ks) . gamToAssocDupL
%%]

%%[20
idDefOccGamByKind :: IdOccKind -> IdDefOccGam -> AssocL HsName IdDefOcc
idDefOccGamByKind k g = [ (n,head i) | (IdOcc n _,i) <- fst (idDefOccGamPartitionByKind [k] g) ]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Identifier unqualified to qualified gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[20 export(IdQualGam)
type IdQualGam = Gam IdOcc HsName
%%]

%%[20 export(idGam2QualGam,idQualGamReplacement)
idGam2QualGam :: IdDefOccGam -> IdQualGam
idGam2QualGam = gamMap (\(iocc,docc) -> (iocc {ioccNm = hsnQualified $ ioccNm iocc},ioccNm $ doccOcc $ docc))

idQualGamReplacement :: IdQualGam -> IdOccKind -> HsName -> HsName
idQualGamReplacement g k n = maybe n id $ gamLookup (IdOcc n k) g
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Instances for Substitutable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[2.Substitutable.Gam
instance (Eq k,Eq tk,Substitutable vv k subst) => Substitutable (Gam tk vv) k subst where
  s |=> (Gam ll)    =   Gam (map (assocLMapElt (s |=>)) ll)
  ftv   (Gam ll)    =   unions . map ftv . map snd . concat $ ll
%%]

%%[9.Substitutable.LGam -2.Substitutable.Gam
instance (Ord tk,Ord k,Substitutable vv k subst) => Substitutable (LGam tk vv) k subst where
  s |=> g    =   gamMapElts (s |=>) g
  ftv   g    =   unions $ map ftv $ gamElts g
%%]

%%[2.Substitutable.inst.ValGamInfo
instance Substitutable ValGamInfo TyVarId VarMp where
  s |=> vgi         =   vgi { vgiTy = s |=> vgiTy vgi }
  ftv   vgi         =   ftv (vgiTy vgi)
%%]

%%[6.Substitutable.inst.TyKiGamInfo
instance Substitutable TyKiGamInfo TyVarId VarMp where
  s |=> tkgi         =   tkgi { tkgiKi = s |=> tkgiKi tkgi }
  ftv   tkgi         =   ftv (tkgiKi tkgi)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pretty printing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.ppGam
ppGam :: (PP k, PP v) => Gam k v -> PP_Doc
ppGam g = ppAssocL (gamToAssocL g)
%%]

%%[1
ppGamDup :: (Ord k,PP k, PP v) => Gam k v -> PP_Doc
ppGamDup g = ppAssocL $ map (\(k,v) -> (k,ppBracketsCommas v)) $ gamToAssocDupL $ g
%%]

%%[1.PP.Gam
instance (PP k, PP v) => PP (Gam k v) where
  pp = ppGam
%%]

%%[9.PP.Gam -1.PP.Gam
instance (PP k, PP v) => PP (LGam k v) where
  pp g = ppGam g
%%]

%%[1.PP.ValGamInfo
instance PP ValGamInfo where
  pp vgi = ppTy (vgiTy vgi)
%%]

%%[4.PP.TyGamInfo
instance PP TyGamInfo where
  pp tgi = ppTy (tgiTy tgi)
%%]

%%[6.PP.TyGamInfo -4.PP.TyGamInfo
instance PP TyGamInfo where
  pp tgi = ppTy (tgiTy tgi)
%%]

%%[6
instance PP TyKiGamInfo where
  pp i = ppTy (tkgiKi i)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ForceEval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[99
instance ForceEval v => ForceEval (LGamElt v) where
  forceEval x@(LGamElt l v) | forceEval v `seq` True = x
%%[[101
  fevCount (LGamElt l v) = cm1 "LGamElt" `cmUnion` fevCount l `cmUnion` fevCount v
%%]]

instance (ForceEval k, ForceEval v) => ForceEval (LGam k v) where
  forceEval x@(LGam l m) | forceEval m `seq` True = x
%%[[101
  fevCount (LGam l m) = cm1 "LGam" `cmUnion` fevCount l `cmUnion` fevCount m
%%]]
%%]

%%[99
instance ForceEval ValGamInfo where
  forceEval x@(ValGamInfo t) | forceEval t `seq` True = x
%%[[101
  fevCount (ValGamInfo x) = cm1 "ValGamInfo" `cmUnion` fevCount x
%%]]

instance ForceEval KiGamInfo where
  forceEval x@(KiGamInfo k) | forceEval k `seq` True = x
%%[[101
  fevCount (KiGamInfo x) = cm1 "KiGamInfo" `cmUnion` fevCount x
%%]]

instance ForceEval TyKiGamInfo where
  forceEval x@(TyKiGamInfo k) | forceEval k `seq` True = x
%%[[101
  fevCount (TyKiGamInfo x) = cm1 "TyKiGamInfo" `cmUnion` fevCount x
%%]]

instance ForceEval TyKiKey
%%[[101
  where
    fevCount (TyKiKey_Name  n) = cm1 "TyKiKey_Name"  `cmUnion` fevCount n
    fevCount (TyKiKey_TyVar v) = cm1 "TyKiKey_TyVar" `cmUnion` fevCount v
%%]]

instance ForceEval TyGamInfo where
  forceEval x@(TyGamInfo t) | forceEval t `seq` True = x
%%[[101
  fevCount (TyGamInfo x) = cm1 "TyGamInfo" `cmUnion` fevCount x
%%]]

instance ForceEval DataFldInfo
%%[[101
  where
    fevCount (DataFldInfo x) = cm1 "DataFldInfo" `cmUnion` fevCount x
%%]]

instance ForceEval DataTagInfo where
  forceEval x@(DataTagInfo m n t p) | forceEval m `seq` forceEval p `seq` True = x
%%[[101
  fevCount (DataTagInfo m n t p) = cmUnions [cm1 "DataTagInfo",fevCount m,fevCount n,fevCount t,fevCount p]
%%]]

instance ForceEval DataFldInConstr where
  forceEval x@(DataFldInConstr m) | forceEval m `seq` True = x
%%[[101
  fevCount (DataFldInConstr x) = cm1 "DataFldInConstr" `cmUnion` fevCount x
%%]]

instance ForceEval DataGamInfo where
  forceEval x@(DataGamInfo n t nl tm cm nt) | forceEval nl `seq` forceEval tm `seq` forceEval cm `seq` True = x
%%[[101
  fevCount (DataGamInfo n t nl tm cm nt) = cmUnions [cm1 "DataGamInfo",fevCount n,fevCount t,fevCount nl,fevCount tm,fevCount cm,fevCount nt]
%%]]

instance ForceEval FixityGamInfo
%%[[101
  where
    fevCount (FixityGamInfo p f) = cm1 "FixityGamInfo" `cmUnion` fevCount p `cmUnion` fevCount f
%%]]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Init of tyGam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1.initTyGam
initTyGam :: TyGam
initTyGam
  = assocLToGam
      [ (hsnArrow,  TyGamInfo (Ty_Con hsnArrow))
      , (hsnInt,    TyGamInfo tyInt)
      , (hsnChar,   TyGamInfo tyChar)
      ]
%%]

%%[6.initTyGam -1.initTyGam
initTyGam :: TyGam
initTyGam
  = assocLToGam
      [ (hsnArrow,      mkTGI (Ty_Con hsnArrow))
      , (hsnInt,        mkTGI tyInt)
      , (hsnChar,       mkTGI tyChar)
%%[[7
      , (hsnRow,        mkTGI (Ty_Con hsnUnknown))
      , (hsnRec,        mkTGI (Ty_Con hsnRec))
      , (hsnSum,        mkTGI (Ty_Con hsnSum))
%%]]
%%[[9
      , (hsnPrArrow,    mkTGI (Ty_Con hsnPrArrow))
%%]]
%%[[97
      , (hsnInteger,    mkTGI tyInteger)
%%]]
      ]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Init of tyKiGam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[6 export(initTyKiGam)
initTyKiGam :: TyKiGam
initTyKiGam
  = gamUnions
      [ (tyKiGamNameSingleton hsnArrow      (TyKiGamInfo ([kiStar,kiStar] `mkArrow` kiStar)))
      , (tyKiGamNameSingleton hsnInt        (TyKiGamInfo kiStar))
      , (tyKiGamNameSingleton hsnChar       (TyKiGamInfo kiStar))
%%[[7
      , (tyKiGamNameSingleton hsnRow        (TyKiGamInfo kiRow))
      , (tyKiGamNameSingleton hsnRec        (TyKiGamInfo ([kiRow] `mkArrow` kiStar)))
      , (tyKiGamNameSingleton hsnSum        (TyKiGamInfo ([kiRow] `mkArrow` kiStar)))
%%]]
%%[[9
      , (tyKiGamNameSingleton hsnPrArrow    (TyKiGamInfo ([kiStar,kiStar] `mkArrow` kiStar)))
%%]]
%%[[97
      , (tyKiGamNameSingleton hsnInteger    (TyKiGamInfo kiStar))
%%]]
      ]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Init of kiGam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[6
initKiGam :: KiGam
initKiGam
  = assocLToGam
      [ (hsnArrow,  KiGamInfo (Ty_Con hsnArrow))
      , (hsnStar,   KiGamInfo kiStar)
%%[[7
      , (hsnRow,    KiGamInfo kiRow)
%%]
      ]
%%]

