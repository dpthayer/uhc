% $Id: EHC.lag 199 2004-05-12 19:11:13Z andres $

%%[0
%include lhs2TeX.fmt
%include afp.fmt

%if style == poly
%format t1
%format t2
%format tf1
%format tf2
%format tr1
%format tr2
%format ta1
%format ta2
%format ty1
%format ty2
%format fi1
%format fi2
%format fo1
%format fo2
%format uqt1
%format uqt2
%endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subsumption (fitting in) for types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[1 import(EHCommon, EHTy, EHError) export (fitsIn, FIOut(..), emptyFO)
%%]

%%[2 import(EHCnstr,EHSubstitutable)
%%]

%%[4 import(EHTyInstantiate, EHGam) export(FIOpts(..), strongFIOpts, instFIOpts, instLFIOpts)
%%]

%%[4 export(FIEnv(..),emptyFE)
%%]

%%[5 export(weakFIOpts)
%%]

%%[6 export(fitsInL)
%%]

%%[7 import(List)
%%]

%%[9 import(Maybe,FiniteMap,Set,UU.Pretty,EHCorePretty,EHPred,EHCore,EHCoreSubst) export(predFIOpts,implFIOpts,prfPreds,foAppCoe,fitPredToEvid)
%%]

%%[9 import(EHDebug) export(fitsIn')
%%]

%%[10 import(EHCoreUtils)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% External interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.FIOpts.hd
data FIOpts =  FIOpts   {  fioLeaveRInst     ::  Bool                ,  fioBindRFirst           ::  Bool
                        ,  fioBindLFirst     ::  Bool                ,  fioUniq                 ::  UID
                        ,  fioCoContra       ::  CoContraVariance 
%%]
%%[6_2
                        ,  fioBindToTyBind   ::  Bool
%%]
%%[7.FIOpts
                        ,  fioNoRLabElimFor  ::  [HsName]
%%]
%%[9.FIOpts
                        ,  fioPredAsTy       ::  Bool                ,  fioAllowRPredElim       ::  Bool
                        ,  fioDontBind       ::  TyVarIdL
%%]
%%[4.FIOpts.tl
                        } deriving Show
%%]

%%[4.strongFIOpts.hd
strongFIOpts :: FIOpts
strongFIOpts =  FIOpts  {  fioLeaveRInst     =   False               ,  fioBindRFirst           =   True
                        ,  fioBindLFirst     =   True                ,  fioUniq                 =   uidStart
                        ,  fioCoContra       =   CoVariant
%%]
%%[6_2
                        ,  fioBindToTyBind   =   False
%%]
%%[7.strongFIOpts
                        ,  fioNoRLabElimFor  =   []
%%]
%%[9.strongFIOpts
                        ,  fioPredAsTy       =   False               ,  fioAllowRPredElim       =   True
                        ,  fioDontBind       =   []
%%]
%%[4.strongFIOpts.tl
                        }
%%]

%%[4.FIOpts.defaults
instLFIOpts :: FIOpts
instLFIOpts = strongFIOpts {fioBindRFirst = False}

instFIOpts :: FIOpts
instFIOpts = instLFIOpts {fioLeaveRInst = True, fioBindLFirst = False}
%%]

%%[5
weakFIOpts :: FIOpts
weakFIOpts = strongFIOpts {fioLeaveRInst = True, fioBindRFirst = False}
%%]

%%[9
predFIOpts :: FIOpts
predFIOpts = strongFIOpts {fioPredAsTy = True, fioLeaveRInst = True}

implFIOpts  :: FIOpts
implFIOpts = strongFIOpts {fioAllowRPredElim = False}
%%]

%%[4
fioSwapVariance :: FIOpts -> FIOpts
fioSwapVariance fio = fio { fioBindRFirst = fioBindLFirst fio, fioBindLFirst = fioBindRFirst fio }
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% App spine Gam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.AppSpine
data AppSpineInfo
  =  AppSpineInfo
       { asCoCo         :: CoContraVariance -> CoContraVariance
       , asFIO          :: FIOpts -> FIOpts
       }

unknownAppSpineInfoL :: AppSpineInfoL
unknownAppSpineInfoL = repeat (AppSpineInfo (const CoContraVariant) id)

arrowAppSpineInfoL :: AppSpineInfoL
arrowAppSpineInfoL = [AppSpineInfo cocoOpp mkStrong ,AppSpineInfo id id]

prodAppSpineInfoL :: AppSpineInfoL
prodAppSpineInfoL = repeat (AppSpineInfo id id)
%%]

%%[9.AppSpine -4.AppSpine
data AppSpineInfo
  =  AppSpineInfo
       { asCoCo         :: CoContraVariance -> CoContraVariance
       , asFIO          :: FIOpts -> FIOpts
       , asFOUpdCoe     :: FIOut -> FIOut -> FIOut
       }

unknownAppSpineInfoL :: AppSpineInfoL
unknownAppSpineInfoL = repeat (AppSpineInfo (const CoContraVariant) id (\_ x -> x))

arrowAppSpineInfoL :: AppSpineInfoL
arrowAppSpineInfoL
  =  [  AppSpineInfo cocoOpp mkStrong
            (\_ x -> x)
     ,  AppSpineInfo id id
            (\ffo afo
                ->  let  (u',u1) = mkNewUID (foUniq afo)
                         n = uidHNm u1
                         r = mkCoe (\e ->  CExpr_Lam n e)
                         l = mkCoe (\e ->  CExpr_App e
                                             (coeWipeWeave emptyCnstr (foCSubst afo) (foLCoeL ffo) (foRCoeL ffo)
                                               `coeEvalOn` CExpr_Var n)
                                   )
                    in   afo  { foRCoeL = r : foRCoeL afo, foLCoeL = l : foLCoeL afo
                              , foUniq = u'
                              }
            )
     ]

prodAppSpineInfoL :: AppSpineInfoL
prodAppSpineInfoL = repeat (AppSpineInfo id id (\_ x -> x))
%%]

%%[4.mkStrong
mkStrong :: FIOpts -> FIOpts
mkStrong fi = fi {fioLeaveRInst = False, fioBindRFirst = True, fioBindLFirst = True}
%%]

%%[6_2.mkStrong -4.mkStrong
mkStrong :: FIOpts -> FIOpts
mkStrong fi = fi {fioLeaveRInst = False, fioBindRFirst = True, fioBindLFirst = True, fioBindToTyBind = False}
%%]

%%[4.AppSpineGam
type AppSpineInfoL = [AppSpineInfo]

data AppSpineGamInfo = AppSpineGamInfo { asgiInfoL :: AppSpineInfoL }

type AppSpineGam = Gam HsName AppSpineGamInfo

asGamLookup :: Ty -> AppSpineGam -> AppSpineInfoL
asGamLookup ty g
  =  case ty of
       Ty_Con nm  ->  case gamLookup nm g of
                        Just ccgi                ->  asgiInfoL ccgi
                        Nothing | hsnIsProd nm   ->  take (hsnProdArity nm) prodAppSpineInfoL
                        _                        ->  unknownAppSpineInfoL
       _          ->  unknownAppSpineInfoL
%%]

%%[4.appSpineGam
appSpineGam :: AppSpineGam
appSpineGam =  assocLToGam [(hsnArrow, AppSpineGamInfo arrowAppSpineInfoL)]
%%]

%%[7.appSpineGam -4.appSpineGam
appSpineGam :: AppSpineGam
appSpineGam =  assocLToGam
                 [ (hsnArrow,    AppSpineGamInfo arrowAppSpineInfoL)
                 , (hsnRec,      AppSpineGamInfo (take 1 prodAppSpineInfoL))
                 ]
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Coercion application
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
foAppCoe :: FIOut -> Cnstr -> CSubst -> CExpr -> CExpr
foAppCoe fo c cs ce
  =  let  s = cs `cAppSubst` foCSubst fo
     in   cAppSubst s (coeWipeWeave c s (foLCoeL fo) (foRCoeL fo) `coeEvalOn` ce)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Internal interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[4.FIIn
data FIIn   =  FIIn     {  fiFIOpts          ::  FIOpts              ,  fiUniq            ::  UID
                        ,  fiCoContra        ::  CoContraVariance
                        }

emptyFI     =  FIIn     {  fiFIOpts          =   strongFIOpts        ,  fiUniq            =   uidStart
                        ,  fiCoContra        =   CoVariant
                        }
%%]

%%[9.FIIn -4.FIIn
data FIIn   =  FIIn     {  fiFIOpts          ::  FIOpts              ,  fiUniq            ::  UID
                        ,  fiCoContra        ::  CoContraVariance    ,  fiEnv             ::  FIEnv
                        }
                        deriving Show

emptyFI     =  FIIn     {  fiFIOpts          =   strongFIOpts        ,  fiUniq            =   uidStart
                        ,  fiCoContra        =   CoVariant           ,  fiEnv             =   emptyFE
                        }
%%]

%%[9
instance Substitutable FIIn where
  s |=> fi  =  let  e = fiEnv fi
               in   fi {fiEnv = e {fePrElimGam = s `gamSubstTop` fePrElimGam e}}
  ftv       =  ftv . gamTop . fePrElimGam . fiEnv

instance PP FIIn where
  pp fi = "FIIn:" >#< pp (fiEnv fi)
%%]

%%[4.FIEnv
data FIEnv  =   FIEnv

emptyFE     =   FIEnv
%%]

%%[9.FIEnv -4.FIEnv
data FIEnv  =   FIEnv   {   fePrElimGam     ::  PrElimGam           ,   feDontBind      ::  TyVarIdL   }
            deriving Show

emptyFE     =   FIEnv   {   fePrElimGam     =   emptyGam            ,   feDontBind      =   []         }

instance PP FIEnv where
  pp e = pp (fePrElimGam e)
%%]

%%[1.FIOut
data FIOut  =   FIOut   { foTy     ::  Ty      ,  foErrL   ::  ErrL    }

emptyFO     =   FIOut   { foTy     =   Ty_Any  ,  foErrL   =   []      }
%%]

%%[2.FIOut -1.FIOut
data FIOut  =  FIOut  {  foTy     ::  Ty      ,  foCnstr           ::  Cnstr
                      ,  foErrL   ::  ErrL
                      }
%%]

%%[2.FIOut.empty
emptyFO     =  FIOut  {  foTy     =   Ty_Any  ,  foCnstr           =   emptyCnstr
                      ,  foErrL   =   []
                      }
%%]

%%[4.FIOut -(2.FIOut 2.FIOut.empty)
data FIOut  =  FIOut    {  foCnstr           ::  Cnstr               ,  foTy              ::  Ty
                        ,  foUniq            ::  UID                 ,  foAppSpineL       ::  AppSpineInfoL
                        ,  foErrL            ::  ErrL
                        }

emptyFO     =  FIOut    {  foCnstr           =   emptyCnstr          ,  foTy              =   Ty_Any
                        ,  foUniq            =   uidStart            ,  foAppSpineL       =   []
                        ,  foErrL            =   []
                        }
%%]

%%[9.FIOut -4.FIOut
data FIOut  =  FIOut    {  foCnstr           ::  Cnstr               ,  foTy              ::  Ty
                        ,  foUniq            ::  UID                 ,  foAppSpineL       ::  AppSpineInfoL
                        ,  foErrL            ::  ErrL                ,  foPredOccL        ::  [PredOcc]
                        ,  foLCoeL           ::  [Coe]               ,  foRCoeL           ::  [Coe]
                        ,  foCSubst          ::  CSubst
%%]
%%[10
                        ,  foRowCoeL         ::  AssocL HsName Coe
%%]
%%[9
                        }
%%]

%%[9.emptyFO
emptyFO     =  FIOut    {  foCnstr           =   emptyCnstr          ,  foTy              =   Ty_Any
                        ,  foUniq            =   uidStart            ,  foAppSpineL       =   []
                        ,  foErrL            =   []                  ,  foPredOccL        =   []
                        ,  foLCoeL           =   []                  ,  foRCoeL           =   []
                        ,  foCSubst          =   emptyCSubst
%%]
%%[10
                        ,  foRowCoeL         =   []
%%]
%%[9
                        }
%%]

%%[1.foHasErrs
foHasErrs :: FIOut -> Bool
foHasErrs = not . null . foErrL
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subsumption
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[fitsInHead.1
fitsIn :: Ty -> Ty -> FIOut
fitsIn ty1 ty2
  =  f ty1 ty2
  where
            res t                                   = emptyFO {foTy = t}
%%]

%%[fitsInBotCon.1
            f  Ty_Any               t2              = res t2
            f  t1                   Ty_Any          = res t1
            f  t1@(Ty_Con s1)
               t2@(Ty_Con s2)
                 | s1 == s2                         = res t2
%%]

%%[fitsInBind.2
            bind tv t                               = (res t) {foCnstr = tv `cnstrTyUnit` t}
            occurBind v t       | v `elem` ftv t    = err [Err_UnifyOccurs ty1 ty2 v t]
                                | otherwise         = bind v t
%%]

%%[fitsInapp.1
            comp tf1 ta1 tf2 ta2 mkComp
                 = foldr1  (\fo1 fo2 -> if foHasErrs fo1 then fo1 else fo2)
                           [ffo,afo,res rt]
                 where  ffo  = f tf1 tf2
                        afo  = f ta1 ta2
                        rt   = mkComp (foTy ffo) (foTy afo)
%%]

%%[fitsInapp.2
            comp tf1 ta1 tf2 ta2 mkComp
                 = foldr1  (\fo1 fo2 -> if foHasErrs fo1 then fo1 else fo2)
                           [ffo,afo,rfo]
                 where  ffo  =   f tf1 tf2
                        fs   =   foCnstr ffo
                        afo  =   f (fs |=> ta1) (fs |=> ta2)
                        as   =   foCnstr afo
                        rt   =   mkComp (as |=> foTy ffo) (foTy afo)
                        rfo  =   emptyFO {foTy = rt, foCnstr = as |=> fs}
%%]

%%[fitsInApp.1
            f  t1@(Ty_App (Ty_App (Ty_Con c1) ta1) tr1)
               t2@(Ty_App (Ty_App (Ty_Con c2) ta2) tr2)
                 | hsnIsArrow c1 && c1 == c2
                 = comp ta2 tr1 ta1 tr2 (\a r -> [a] `mkTyArrow` r)
            f  t1@(Ty_App tf1 ta1)
               t2@(Ty_App tf2 ta2)
                 = comp tf1 ta1 tf2 ta2 Ty_App
%%]

%%[fitsInRest.1
            f  t1                   t2              = err [Err_UnifyClash ty1 ty2 t1 t2]
            err e                                   = emptyFO {foErrL = e}
%%]

%%[1.fitsIn.Base
%%@fitsInHead.1
%%@fitsInBotCon.1
%%]

%%[1.fitsIn.AppRest
%%@fitsInApp.1
%%@fitsInRest.1
%%@fitsInapp.1
%%]

%%[2.fitsIn.Base -(1.fitsIn.Base 1.fitsIn.AppRest)
%%@fitsInHead.1
%%]

%%[2.fitsIn.Bind
%%@fitsInBind.2
%%]

%%[2.fitsIn.app
%%@fitsInapp.2
%%]

%%[2.fitsIn.BotCon
%%@fitsInBotCon.1
%%]

%%[2.fitsIn.Var
            f  t1@(Ty_Var v1)       (Ty_Var v2)     ^^
                 | v1 == v2                         = res t1
            f  t1@(Ty_Var v1)       t2              = occurBind v1 t2
            f  t1                   t2@(Ty_Var v2)  = occurBind v2 t1
%%]

%%[2.fitsIn.AppRest
%%@fitsInApp.1
%%@fitsInRest.1
%%]

%%[3.fitsIn -(2.fitsIn.Base 2.fitsIn.Bind 2.fitsIn.app 2.fitsIn.BotCon 2.fitsIn.Var 2.fitsIn.AppRest)
%%@fitsInHead.1
%%@fitsInBind.2
%%@fitsInapp.2
%%@fitsInBotCon.1
            f  t1@(Ty_Var v1 f1)    (Ty_Var v2 f2)  ^^
                 | v1 == v2 && f1 == f2             = res t1
            f  t1@(Ty_Var v1 f)     t2              
                 | f == TyVarCateg_Plain            = occurBind v1 t2
            f  t1                   t2@(Ty_Var v2 f)
                 | f == TyVarCateg_Plain            = occurBind v2 t1
%%@fitsInApp.1
%%@fitsInRest.1
%%]

%%[4.fitsIn.Prelim -3.fitsIn
fitsIn :: FIOpts -> FIEnv -> UID -> Ty -> Ty -> FIOut
fitsIn opts env uniq ty1 ty2
  =  fo
  where
            res fi t                =  emptyFO  { foUniq = fiUniq fi, foTy = t
                                                , foAppSpineL = asGamLookup t appSpineGam}
            err fi e                =  emptyFO {foUniq = fioUniq opts, foErrL = e}
            manyFO fos              =  foldr1 (\fo1 fo2 -> if foHasErrs fo1 then fo1 else fo2) fos
            occurBind fi v t
                | v `elem` ftv t    =  err fi [Err_UnifyOccurs ty1 ty2 v t]
                | otherwise         =  bind fi v t
%%]

%%[4.fitsIn.bind
            bind fi tv t            =  (res fi t) {foCnstr = tv `cnstrTyUnit` t}
%%]

%%[6_2
            mkTyBind fi tv t        =  if fioBindToTyBind (fiFIOpts fi) then Ty_Bind tv [t] else t
%%]

%%[4.fitsIn.allowBind
            allowBind fi v          =  True
%%]

%%[9.fitsIn.allowBind -4.fitsIn.allowBind
            allowBind fi v          =  v `notElem` fioDontBind (fiFIOpts fi)
%%]

%%[4.fitsIn.allowImpredTVBind
            allowImpredTVBindL fi (Ty_Var v f) _
                = fioBindLFirst (fiFIOpts fi) && f == TyVarCateg_Plain && allowBind fi v
            allowImpredTVBindR fi (Ty_Var v f) _
                = fioBindRFirst (fiFIOpts fi) && f == TyVarCateg_Plain && allowBind fi v
%%]

%%[99.fitsIn.allowImpredTVBind -4.fitsIn.allowImpredTVBind
            allowImpredTVBindL fi (Ty_Var _ f) t
                = fioBindLFirst (fiFIOpts fi) && f == TyVarCateg_Plain && not (tyIsImplsTail . fst . tyArrowArgRes $ t)
            allowImpredTVBindR fi (Ty_Var _ f) t
                = fioBindRFirst (fiFIOpts fi) && f == TyVarCateg_Plain && not (tyIsImplsTail . fst . tyArrowArgRes $ t)
%%]

%%[4.fitsIn.unquant
            unquant fi t@(Ty_Quant _ _ _) hide howToInst
                =   let  (u,uq)         = mkNewLevUID (fiUniq fi)
                         (uqt,rtvs)     = tyInst1Quants uq howToInst t
                         back           = if hide  then  \fo ->  let  s = cnstrFilter (const.not.(`elem` rtvs)) (foCnstr fo)
                                                                 in   fo {foCnstr = s, foTy = s |=> t}
                                                   else  id
                    in   (fi {fiUniq = u},uqt,back)
%%]

%%[4
            foUpdTy  t   fo = fo {foTy = t}
            foUpdCnstr c fo = fo {foCnstr = c |=> foCnstr fo}
%%]

%%[4.fitsIn.foCmb
            foCmbAppTy   ffo afo  = afo {foTy = Ty_App (foCnstr afo |=> foTy ffo) (foTy afo)}
            foCmbCnstr   ffo afo  = afo {foCnstr = foCnstr afo |=> foCnstr ffo}
            foCmbCoCon   ffo afo  = afo {foAppSpineL = tail (foAppSpineL ffo)}
%%]

%%[9
            foCmbPrL     ffo afo  = afo {foPredOccL = foPredOccL afo ++ foPredOccL ffo}
            foCmbCSubst  ffo afo  = afo {foCSubst = foCSubst afo `cAppSubst` foCSubst ffo}
%%]

%%[4.fitsIn.foCmbApp
            foCmbApp     ffo      = foCmbCoCon ffo . foCmbCnstr ffo . foCmbAppTy ffo
%%]

%%[9.fitsIn.foCmbApp -4.fitsIn.foCmbApp
            foCmbApp     ffo      = foCmbPrfRes ffo . foCmbCoCon ffo . foCmbCnstr ffo . foCmbAppTy ffo
%%]

%%[7.fitsIn.foCmbPrfRes
            foCmbPrfRes  ffo afo  = afo
%%]

%%[9.fitsIn.foCmbPrfRes -7.fitsIn.foCmbPrfRes
            foCmbPrfRes  ffo      = foCmbCSubst ffo . foCmbPrL ffo
%%]

%%[9
            fiAddPr n i prTy fi
                =  let  e = fiEnv fi
                        g = peGamAddKnPr n i (tyPred prTy) (fePrElimGam e)
                   in   fi { fiEnv = e {fePrElimGam = g} }
            foUpdErrs e fo = fo {foErrL = e ++ foErrL fo}
            foUpdLCoe l fo = fo {foLCoeL = l : foLCoeL fo}
            foUpdRCoe r fo = fo {foRCoeL = r : foRCoeL fo}
            foUpdLRCoe l r = foUpdLCoe l . foUpdRCoe r
            foUpdPrL prL fo = fo {foPredOccL = prL ++ foPredOccL fo}
            foUpdCSubst s fo = fo {foCSubst = s `cAppSubst` foCSubst fo}
            foUpdImplExpl iv im tpr fo
                            = foUpdCnstr (iv `cnstrImplsUnit` (foCnstr fo |=> im))
                            . foUpdTy ([foCnstr fo |=> tpr] `mkTyArrow` foTy fo)
                            $ fo
            foUpdImplExplCoe iv im tpr lCoe rCoe fo
                            = foUpdImplExpl iv im tpr . foUpdLRCoe lCoe rCoe $ fo
%%]

%%[6
            fPairWise' f fi tL1 tL2
              =  foldr  (\(t1,t2) (foL,fii,c)
                           -> let  fo = f (fii) (c |=> t1) (c |=> t2)
                              in   (fo:foL,fii {fiUniq = foUniq fo},foCnstr fo |=> c))
                        ([],fi,emptyCnstr)
                        (zip tL1 tL2)
            fPairWise = fPairWise' f
%%]

%%[7.fitsIn.fRow.Base
            fRow fi tr1 tr2 isRec isSum
                = foR
                where  (r1,exts1) = tyRowExts tr1
                       (r2,exts2) = tyRowExts tr2
                       (extsIn1,extsIn12,extsIn2) = split (tyRowCanonOrder exts1) (tyRowCanonOrder exts2)
                       split ees1@(e1:es1) ees2@(e2:es2)
                         = case e1 `rowExtCmp` e2 of
                               EQ -> let (es1',es12,es2') = split es1  es2  in (es1',(e1,e2):es12,es2')
                               LT -> let (es1',es12,es2') = split es1  ees2 in (e1:es1',es12,es2')
                               GT -> let (es1',es12,es2') = split ees1 es2  in (es1',es12,e2:es2')
                       split ees1 ees2
                         = (ees1,[],ees2)
                       mkTv fi    = (fi',mkTyVar u)
                         where  (u',u) = mkNewUID (fiUniq fi)
                                fi' = fi {fiUniq = u'}
                       bind fo v r e = manyFO [fo,foUpdTy (foTy fo `mkTyRow` e') . foUpdCnstr (v `cnstrTyUnit` mkTyRow r' e') $ fo]
                         where  e' = foCnstr fo |=> e
                                r' = foCnstr fo |=> r
                       (u',u1)    = mkNewLevUID (fiUniq fi)
                       fi2        = fi {fiUniq = u'}
                       
                       fR fi r1 r2@(Ty_Var v2 f2) e1@(_:_) e12 e2
                         | f2 == TyVarCateg_Plain
                         = bind (fR fi2 r1 rv [] e12 e2) v2 rv e1
                         where  (fi2,rv) = mkTv fi
                       fR fi r1@(Ty_Var v1 f1) r2 e1 e12 e2@(_:_)
                         | f1 == TyVarCateg_Plain
                         = bind (fR fi2 rv r2 e1 e12 []) v1 rv e2
                         where  (fi2,rv) = mkTv fi
                       fR fi r1@(Ty_Con n1) _ _ _ e2@(_:_)
                         | n1 == hsnRowEmpty && isRec
                         = err fi [Err_MissingRowLabels (assocLKeys e2) tr1]
                       fR fi _ r2@(Ty_Con n2) e1@(_:_) e12 e2
                         | n2 == hsnRowEmpty && isRec
                         =  if null (fioNoRLabElimFor (fiFIOpts fi) `List.intersect` assocLKeys e1)
                            then fR fi r2 r2 [] e12 e2
                            else err fi [Err_TooManyRowLabels (assocLKeys e1) tr2]
                       fR fi r1@(Ty_Con n1) _ e1 e12 e2@(_:_)
                         | n1 == hsnRowEmpty && isSum
                         = fR fi r1 r1 e1 e12 []
                       fR fi r1 r2@(Ty_Con n2) e1@(_:_) e12 e2
                         | n2 == hsnRowEmpty && isSum
                         = err fi [Err_MissingRowLabels (assocLKeys e1) tr2]
                       fR fi r1 r2 e1 e12@(_:_) e2
                         = foR
                         where (e1L,e2L) = unzip e12
                               (foL,fi2,fCnstr) = fPairWise (fi {fiFIOpts = strongFIOpts}) (assocLElts e1L) (assocLElts e2L)
                               eKeys = assocLKeys e1L
                               eL = zip eKeys (map ((fCnstr |=>) . foTy) foL)
                               fo = fR fi2 r1 r2 e1 [] e2
                               foR = manyFO ([fo] ++ foL ++ [foRes])
                               foRes = (\fo -> foldr foCmbPrfRes fo foL)
%%]
%%[10
                                       . foUpdRecFldsCoe eKeys foL tr1
%%]
%%[7
                                       . foUpdTy (foTy fo `mkTyRow` eL)
                                       . foUpdCnstr fCnstr $ fo
%%]

%%[7.fitsIn.fRow.fRFinal
                       fR fi r1 r2 [] [] []
                         = f fi r1 r2
%%]

%%[10.fitsIn.fRow.fRFinal -7.fitsIn.fRow.fRFinal
                       fR fi r1@(Ty_Var _ TyVarCateg_Fixed) r2@(Ty_Con n2) [] [] []
                         | n2 == hsnRowEmpty && isRec
                         = res fi r2
                       fR fi r1 r2 [] [] []
                         = (f fi r1 r2) {foLCoeL = [], foRCoeL = []}
%%]

%%[7.fitsIn.fRow.Final1
                       fR fi _ _ _ _ _
                         = err fi [Err_UnifyClash ty1 ty2 tr1 tr2]
%%]

%%[7.fitsIn.fRow.foR
                       foR        = fR fi2 r1 r2 extsIn1 extsIn12 extsIn2
%%]

%%[10.fitsIn.fRow.foR -7.fitsIn.fRow.foR
                       fo         = fR fi2 r1 r2 extsIn1 extsIn12 extsIn2
                       foR        = (if isRec then foUpdRecCoe (foCnstr fo |=> r1) (foCnstr fo |=> r2) extsIn1 extsIn12 extsIn2 else id) fo 
                       foUpdRecCoe r1 r2 e1 e12 e2 fo
                         =  let  rn = uidHNm u1
                                 r = CExpr_Var rn
                                 tr1s = foCnstr fo |=> tr1
                                 (u',u2,u3,u4) = mkNewLevUID3 (foUniq fo)
                                 mkLSel n u = mkCExprSelCase emptyRCEEnv (hsnSuffix rn "!") r CTagRec n n (CExpr_Hole u)
                                 mkLPred' r l u
                                   =  let  r' = maybe Ty_Any fst . tyRowExtr l $ r
                                      in   (PredOcc (Pred_Lacks r' l) u,r')
                                 mkLPred r l u = fst (mkLPred' r l u)
                                 rowCoeL = [ rc | rc@(_,c) <- sortByOn rowLabCmp fst (foRowCoeL fo), not (coeIsId c) ]
                                 (fuUpdL,prUpdL,tr1s',_)
                                   =  foldr  (\(l,c) (fuL,prL,r,u)
                                                ->  ((l,CExpr_TupUpd cvarUndefined CTagRec l (CExpr_Hole u) (c `coeEvalOn` mkLSel l u)):fuL
                                                    ,mkLPred r l u : prL,r,uidNext u
                                                    )
                                             )
                                             ([],[],tr1s,u2) rowCoeL
                                 (fuDelL,prDelL,_,_)
                                   =  foldl  (\(fuL,prL,r,u) l
                                                  ->  let  (pr,r') = mkLPred' r l u
                                                      in   ((l,CExpr_TupDel (CExpr_Var hsnWild) CTagRec l (CExpr_Hole u)):fuL
                                                           ,pr:prL,r',uidNext u
                                                           )
                                             )
                                             ([],[],tr1s',u3) (sortBy rowLabCmp (assocLKeys e1))
                                 fuL = fuUpdL ++ reverse fuDelL
                                 (fBldL,prBldL,_,_)
                                   =  foldr  (\l (fL,prL,r,u)
                                                ->  ((maybe id coeEvalOn (lookup l rowCoeL) $ mkLSel l u):fL
                                                    ,mkLPred r l u : prL,r,uidNext u
                                                    )
                                             )
                                             ([],[],tr1s,u3) (sortBy rowLabCmp ((assocLKeys . map fst $ e12) ++ assocLKeys e2))
                            in   case r2 of
                                   Ty_Con n2 | n2 == hsnRowEmpty
                                     ->  fo  {  foLCoeL = [Coe (\e -> mkCExprLet CBindPlain [CBind_Bind rn e] (CExpr_Tup CTagRec `mkCExprApp` fBldL))]
                                             ,  foPredOccL = prBldL ++ foPredOccL fo
                                             ,  foUniq = u'
                                             }
                                   Ty_Var _ TyVarCateg_Fixed | not (null fuL)
                                     ->  fo  {  foLCoeL = [Coe (\e -> mkCExprLet CBindPlain [CBind_Bind rn e] (fuMkCExpr u4 fuL r))]
                                             ,  foPredOccL = prUpdL ++ prDelL ++ foPredOccL fo
                                             ,  foUniq = u'
                                             }
                                   _ |  not (null fuUpdL)
                                     ->  fo  {  foLCoeL = [Coe (\e -> mkCExprLet CBindPlain [CBind_Bind rn e] (fuMkCExpr u4 fuUpdL r))]
                                             ,  foPredOccL = prUpdL ++ foPredOccL fo
                                             ,  foUniq = u'
                                             }
                                     |  otherwise
                                     ->  fo  {  foLCoeL = [] }
%%]

%%[10.fitsIn.fRow.Coe
                       foUpdRecFldsCoe eKeys foL tr1 foR
                         =  let cL =   [  (l,c)
                                       |  (l,fo) <- zip eKeys foL
                                       ,  let c = coeWipeWeave (foCnstr foR) (foCSubst foR) (foLCoeL fo) (foRCoeL fo)
                                       ,  not (coeIsId c)
                                       ]
                            in  foR {foRowCoeL = cL}
%%]

%%[4.fitsIn.Base
            f fi t1                     t2
                | fiCoContra fi == ContraVariant    = f  (fi  { fiCoContra = CoVariant
                                                              , fiFIOpts = fioSwapVariance (fiFIOpts fi)})
                                                         t2 t1
            f fi Ty_Any                 t2          = res fi t2
            f fi t1                     Ty_Any      = res fi t1
            f fi t1@(Ty_Con s1)         t2@(Ty_Con s2)
                | s1 == s2                          = res fi t2
            f fi t1@(Ty_Var v1 f1)      (Ty_Var v2 f2)
                | v1 == v2 && f1 == f2              = res fi t1
%%]

%%[4.fitsIn.Var1
            f fi t1@(Ty_Var v1 _)       t2
                | allowImpredTVBindL fi t1 t2       = occurBind fi v1 t2
            f fi t1                     t2@(Ty_Var v2 _)
                | allowImpredTVBindR fi t2 t1       = occurBind fi v2 t1
%%]

%%[6_2.fitsIn.Var1 -4.fitsIn.Var1
            f fi t1@(Ty_Var v1 _)       t2
                | allowImpredTVBindL fi t1 t2       = occurBind fi v1 (mkTyBind fi v1 t2)
            f fi t1                     t2@(Ty_Var v2 _)
                | allowImpredTVBindR fi t2 t1       = occurBind fi v2 (mkTyBind fi v2 t1)
%%]

%%[6_2
            f fi t1@(Ty_Bind v1 t1L@(_:_))  t2          = fo2
                where  bind tv t fo =  foUpdCnstr (tv `cnstrTyUnit` t) . foUpdTy t $ fo
                       fo2 =  case t2 of
                                  Ty_Quant q2 _ _ | tyquIsForall q2
                                      ->  bind v1 (Ty_Bind v1 [c |=> t2]) . foUpdCnstr c $ fo
                                          where  (foL@(fo:_),_,c) = fPairWise fi (repeat t2) t1L
                                  _   | any foHasErrs foL  ->  bind v1 (Ty_Bind v1 (t2:t1L)) (emptyFO {foUniq = fiUniq fi})
                                      | otherwise          ->  bind v1 (Ty_Bind v1 [foTy fo]) . foUpdCnstr c $ fo
                                          where  (foL@(fo:_),_,c) = fPairWise fi t1L (repeat t2)
%%]
                       fo2 =  if any foHasErrs foL
                              then  case t2 of
                                      Ty_Quant q2 _ _ | tyquIsForall q2
                                        ->  bind v1 (Ty_Bind v1 [c |=> t2]) . foUpdCnstr c $ fo
                                        where  (foL@(fo:_),fi2,c) = fPairWise' (\fi -> flip (f fi)) fi (repeat t2) t1L
                                      _ ->  bind v1 (Ty_Bind v1 (t2:t1L)) (emptyFO {foUniq = fiUniq fi})
                              else  bind v1 (Ty_Bind v1 [foTy fo]) . foUpdCnstr c $ fo

%%[9
            f fi t1@(Ty_Pred (Pred_Class ct1)) t2@(Ty_Pred (Pred_Class ct2))
                | fioPredAsTy (fiFIOpts fi)         = fo {foTy = Ty_Pred (Pred_Class (foTy fo))} 
                where  fo = f fi ct1 ct2
%%]

%%[10
            f fi t1@(Ty_Pred (Pred_Lacks lt1 l1)) t2@(Ty_Pred (Pred_Lacks lt2 l2))
                | fioPredAsTy (fiFIOpts fi) && l1 == l2
                                                    = fo {foTy = Ty_Pred (Pred_Lacks (foTy fo) l1)} 
                where  fo = f fi lt1 lt2
%%]

%%[4.fitsIn.QLR
            f fi t1@(Ty_Quant q1 _ _)   t2@(Ty_Quant q2 _ _)
                | fiCoContra fi == CoContraVariant && q1 == q2
                                                    = f fi2 uqt1 uqt2
                where  (fi1,uqt1,_) = unquant fi   t1 False instCoConst
                       (fi2,uqt2,_) = unquant fi1  t2 False instCoConst
%%]

%%[4.fitsIn.QR
            f fi t1                     t2@(Ty_Quant _ _ _)
                | fiCoContra fi /= CoContraVariant && fioLeaveRInst (fiFIOpts fi)
                                                    = back2 (f fi2 t1 uqt2)
                where (fi2,uqt2,back2) = unquant fi t2 False instCoConst
            f fi t1                     t2@(Ty_Quant _ _ _)
                | fiCoContra fi /= CoContraVariant && not (fioLeaveRInst (fiFIOpts fi))
                                                    = back2 (f fi2 t1 uqt2)
                where (fi2,uqt2,back2) = unquant fi t2 True instContra
%%]

%%[4.fitsIn.QL
            f fi t1@(Ty_Quant _ _ _)    t2
                | fiCoContra fi /= CoContraVariant  = f fi1 uqt1 t2
                where (fi1,uqt1,back1) = unquant fi t1 False instCoConst
%%]

%%[9
            f fi  t1@(Ty_App (Ty_App (Ty_Con c1) tpr1) tr1)
                  t2@(Ty_App (Ty_App (Ty_Con c2) tpr2) tr2)
                    | hsnIsArrow c1 && c1 == c2 && not (fioPredAsTy (fiFIOpts fi)) && isJust mbfp
                = fromJust mbfp
                where  (u',u1,u2,u3)    = mkNewLevUID3 (fiUniq fi)
                       fi2              = fi {fiUniq = u'}
                       mbfp             = fP tpr1 tpr2
                       mberr            = Just (err fi [Err_UnifyClash ty1 ty2 t1 t2])
                       fP tpr1@(Ty_Pred _)              tpr2@(Ty_Pred _)
                            =  if foHasErrs pfo
                               then Nothing
                               else Just  ( foUpdTy ([foCnstr fo |=> foTy pfo] `mkTyArrow` foTy fo)
                                          . foUpdLRCoe (mkAppCoe emptyFM [CExpr_Var n]) (mkLamCoe n)
                                          $ fo)
                            where  pfo   = f (fi2 {fiFIOpts = predFIOpts}) tpr2 tpr1
                                   n     = uidHNm u2
                                   fo    = f (fi2 {fiUniq = foUniq pfo}) (foCnstr pfo |=> tr1) (foCnstr pfo |=> tr2)
                       fP tpr1@(Ty_Pred pr1)            (Ty_Impls (Impls_Tail iv2))
                            =  Just (foUpdImplExplCoe iv2 (Impls_Cons iv2 pr1 u2 im2) tpr1 (mkAppCoe emptyFM [CExpr_Var n]) (mkLamCoe n) fo)
                            where  im2   = Impls_Tail u1
                                   n     = uidHNm u2
                                   fo    = f fi2 tr1 ([Ty_Impls im2] `mkTyArrow` tr2)
                       fP (Ty_Impls (Impls_Tail iv1))   tpr2@(Ty_Pred pr2)
                            =  Just (foUpdImplExplCoe iv1 (Impls_Cons iv1 pr2 u2 im1) tpr2 (mkAppCoe emptyFM [CExpr_Var n]) (mkLamCoe n) fo)
                            where  im1   = Impls_Tail u1
                                   n     = uidHNm u2
                                   fo    = f fi2 ([Ty_Impls im1] `mkTyArrow` tr1) tr2
                       fP (Ty_Impls (Impls_Tail iv1))   tpr2@(Ty_Impls im2@(Impls_Nil))
                            =  Just (foUpdImplExpl iv1 im2 tpr2 (f fi2 tr1 tr2))
                       fP (Ty_Impls (Impls_Nil))   tpr2@(Ty_Impls im2@(Impls_Tail iv2))
                            =  Just (foUpdImplExpl iv2 Impls_Nil (Ty_Impls Impls_Nil) (f fi2 tr1 tr2))
                       fP (Ty_Impls (Impls_Tail iv1))   tpr2@(Ty_Impls im2@(Impls_Tail iv2))
                            =  Just (foUpdImplExplCoe iv1 im2 tpr2 (CoeImplApp iv2) (CoeImplLam iv2) (f fi2 tr1 tr2))
                       fP (Ty_Impls Impls_Nil)          (Ty_Impls Impls_Nil)
                            =  Just (f fi2 tr1 tr2)
                       fP (Ty_Impls Impls_Nil)          (Ty_Impls _)
                            =  mberr
                       fP (Ty_Impls Impls_Nil)          (Ty_Pred _)
                            =  mberr
                       fP (Ty_Impls _)                  (Ty_Impls Impls_Nil)
                            =  mberr
                       fP (Ty_Pred _)                   (Ty_Impls Impls_Nil)
                            =  mberr
                       fP _                             _
                            =  Nothing
            f fi  t1
                  t2@(Ty_App (Ty_App (Ty_Con c2) tpr2) tr2)
                    | hsnIsArrow c2 && not (fioPredAsTy (fiFIOpts fi)) && isJust mbfp
                = fromJust mbfp
                where  (u',u1)          = mkNewLevUID (fiUniq fi)
                       fi2              = fi {fiUniq = u'}
                       mbfp             = fP tpr2
                       mkPrTy pr2 fo    = [Ty_Pred (foCnstr fo |=> pr2)] `mkTyArrow` foTy fo
                       fSub pr2v pr2 tr2
                            =  let  pr2n  = uidHNm pr2v
                                    fo    = f (fiAddPr pr2n pr2v tpr2 fi2) t1 tr2
                               in   (fo,mkLamCoe pr2n)
                       fP (Ty_Impls (Impls_Nil))
                            =  Just fo
                            where fo = f fi2 t1 tr2
                       fP (Ty_Impls (Impls_Tail iv2))
                            =  Just (foUpdCnstr (iv2 `cnstrImplsUnit` Impls_Nil) fo)
                            where fo = f fi2 t1 tr2
                       fP (Ty_Impls (Impls_Cons _ pr2 pv2 im2))
                            =  Just (foUpdRCoe rCoe . foUpdTy (mkPrTy pr2 fo) $ fo)
                            where (fo,rCoe) = fSub pv2 pr2 ([Ty_Impls im2] `mkTyArrow` tr2)
                       fP (Ty_Pred pr2)  | fioAllowRPredElim (fiFIOpts fi)
                            =  Just (foUpdRCoe rCoe . foUpdTy (mkPrTy pr2 fo) $ fo)
                            where (fo,rCoe) = fSub u1 pr2 tr2
                       fP _ =  Nothing
            f fi  t1@(Ty_App (Ty_App (Ty_Con c1) tpr1) tr1)
                  t2
                    | hsnIsArrow c1 && not (fioPredAsTy (fiFIOpts fi)) && isJust mbfp
                = fromJust mbfp
                where  (u',u1,u2,u3)    = mkNewLevUID3 (fiUniq fi)
                       fi2              = fi {fiUniq = u'}
                       mbfp             = fP tpr1
                       fSub pr1 pv1 tr1
                            =  let  fo    = f fi2 tr1 t2
                                    fs    = foCnstr fo
                                    (cbindLMap,csubst,remPrfPrL,evidL,prfErrs) = prfPreds u3 (fiEnv (fs |=> fi2)) [PredOcc (fs |=> pr1) pv1]
                               in   (foUpdErrs prfErrs fo,mkAppCoe cbindLMap evidL,csubst,remPrfPrL)
                       fP (Ty_Impls (Impls_Nil))
                            =  Just (f fi2 tr1 t2)
                       fP (Ty_Impls (Impls_Tail iv1))
                            =  Just (foUpdCnstr (iv1 `cnstrImplsUnit` Impls_Nil) (f fi2 tr1 t2))
                       fP (Ty_Impls (Impls_Cons _ pr1 pv1 im1))
                            =  Just (foUpdPrL remPrfPrL . foUpdLCoe lCoe . foUpdCSubst csubst $ fo)
                            where (fo,lCoe,csubst,remPrfPrL) = fSub pr1 pv1 ([Ty_Impls im1] `mkTyArrow` tr1)
                       fP (Ty_Pred pr1)  | fioAllowRPredElim (fiFIOpts fi)
                            =  Just (foUpdPrL remPrfPrL . foUpdLCoe lCoe . foUpdCSubst csubst $ fo)
                            where (fo,lCoe,csubst,remPrfPrL) = fSub pr1 u1 tr1
                       fP _ =  Nothing
%%]

                       fP im2@(Ty_Impls (Impls_Nil))
                            =  Just (foUpdTy ([im2] `mkTyArrow` foTy fo) $ fo)
                            where fo = f fi2 t1 tr2
                       fP (Ty_Impls (Impls_Tail iv2))
                            =  Just (foUpdCnstr (iv2 `cnstrImplsUnit` Impls_Nil) . foUpdTy ([Ty_Impls (Impls_Nil)] `mkTyArrow` foTy fo) $ fo)
                            where fo = f fi2 t1 tr2

%%[7
            f fi  t1@(Ty_App (Ty_Con n1) tr1)
                  t2@(Ty_App (Ty_Con n2) tr2)
                | n1 == n2 && (isRec || isSum)
                = foUpdTy (n1 `mkTyConApp` [foTy fo]) fo
                where  isRec = hsnIsRec n1
                       isSum = hsnIsSum n1
                       fo = fRow fi tr1 tr2 isRec isSum
%%]

%%[4.fitsIn.Var2
            f fi t1@(Ty_Var v1 f)       t2
                | f == TyVarCateg_Plain && allowBind fi v1
                                                    = occurBind fi v1 t2
            f fi t1                     t2@(Ty_Var v2 f)
                | f == TyVarCateg_Plain && allowBind fi v2
                                                    = occurBind fi v2 t1
%%]

%%[6_2.fitsIn.Var2 -4.fitsIn.Var2
            f fi t1@(Ty_Var v1 f)       t2
                | f == TyVarCateg_Plain && allowBind fi v1
                                                    = occurBind fi v1 (mkTyBind fi v1 t2)
            f fi t1                     t2@(Ty_Var v2 f)
                | f == TyVarCateg_Plain && allowBind fi v2
                                                    = occurBind fi v2 (mkTyBind fi v2 t1)
%%]

%%[4.fitsIn.App
            f fi t1@(Ty_App tf1 ta1)    t2@(Ty_App tf2 ta2)
                = manyFO [ffo,afo,foCmbApp ffo afo]
                where  ffo  = f fi tf1 tf2
                       fs   = foCnstr ffo
                       (as:_) = foAppSpineL ffo
                       fi'  = fi  { fiCoContra  = (asCoCo as) (fiCoContra fi), fiFIOpts = (asFIO as) (fiFIOpts fi)
                                  , fiUniq      = foUniq ffo }
                       afo  = f fi' (fs |=> ta1) (fs |=> ta2)
%%]

%%[9.fitsIn.App -4.fitsIn.App
            f fi t1@(Ty_App tf1 ta1)    t2@(Ty_App tf2 ta2)
                = manyFO [ffo,afo,rfo]
                where  ffo  = f fi tf1 tf2
                       fs   = foCnstr ffo
                       (as:_) = foAppSpineL ffo
                       fi'  = fi  { fiCoContra  = (asCoCo as) (fiCoContra fi), fiFIOpts = (asFIO as) (fiFIOpts fi)
                                  , fiUniq      = foUniq ffo }
                       afo  = f fi' (fs |=> ta1) (fs |=> ta2)
                       rfo  = asFOUpdCoe as ffo . foCmbApp ffo $ afo
%%]

%%[7.fitsIn.Ext
            f fi t1@(Ty_Ext _ _ _)   t2@(Ty_Ext _ _ _)
                =  fRow fi t1 t2 False False
%%]

%%[4.fitsIn.DefaultCase
            f fi t1                     t2          = err fi [Err_UnifyClash ty1 ty2 t1 t2]
%%]

%%[4.fitsIn.SetupAndResult
            fo  = f (emptyFI {fiUniq = uniq, fiFIOpts = opts, fiCoContra = fioCoContra opts}) ty1 ty2
%%]

%%[9.fitsIn.SetupAndResult -4.fitsIn.SetupAndResult
            fo  = f  (emptyFI  { fiUniq = uniq, fiFIOpts = opts, fiCoContra = fioCoContra opts
                               , fiEnv = env { fePrElimGam = gamPushNew (fePrElimGam env) } }
                     ) ty1 ty2
%%]

%%[9
            f' msg fi t1 t2 = let fo = f (trPP ("FIT" ++ "-" ++ msg ++ "-" ++ "fi") fi) (m "t1" t1) (m "t2" t2)
                                  m mm x = trPP ("FIT" ++ "-" ++ msg ++ "-" ++ mm) x
                              in  tr ("FIT" ++ "-" ++ msg) (pp (foTy fo)) fo
%%]

%%[9
fitsIn' :: String -> FIOpts -> FIEnv -> UID -> Ty -> Ty -> FIOut
fitsIn' msg opts env uniq ty1 ty2
  =  fitsIn opts (trPP (msg ++ "-env") env) (trPP (msg ++ "-uniq") uniq) (trPP (msg ++ "-ty1") ty1) (trPP (msg ++ "-ty2") ty2)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subsumption for lists of types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[6
fitsInL :: FIOpts -> FIEnv -> UID -> TyL -> TyL -> (TyL,FIOut)
fitsInL opts env uniq tyl1 tyl2
  =  snd
     .  foldr  (\(t1,t2) (u,(ts,fos))
                  -> let  (u',ue) = mkNewLevUID u
                          fo = fitsIn opts env u (foCnstr fos |=> t1) (foCnstr fos |=> t2)
                     in   (u',(foTy fo:ts, fos {foCnstr = foCnstr fo |=> foCnstr fos, foErrL = foErrL fo ++ foErrL fos}))
               )
               (uniq,([],emptyFO))
     .  zip tyl1 $ tyl2
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Proof of predicates, must be here because of mutual dep with fitsIn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
prfPreds :: UID -> FIEnv -> [PredOcc] -> (CBindLMap,CSubst,[PredOcc],[CExpr],[Err])
prfPreds u env prL
  =  let  env'                          = env
          prL'                          = prL
          (g,prvnErrs)                  = prfPredsToProvenGraph u env' prL'
          (g',gOr)                      = prfPredsPruneProvenGraph prL' g
          overl                         = [ (pr,map (\e -> case lookupFM (prvgIdNdMp gOr) e of {Just (ProvenAnd _ _ _ ev) -> ev; _ -> CExpr_Hole e}) es)
                                          | (ProvenOr pr es _) <- eltsFM (prvgIdNdMp gOr)
                                          ]
          (cbindLMap,csubst,remPrIdSet)
                                        = prvgCode prL' g'
          elemOf p s                    = poId p `elementOf` s
          remPrL                        = [ PredOcc p i | (i,ProvenArg p _) <- fmToList . prvgIdNdMp $ g' ]
     in   ( cbindLMap,csubst,remPrL,map (\po -> CExpr_Hole . poId $ po) prL
          , (if null overl then [] else [Err_OverlapPreds overl]) ++ prvnErrs
          )
%%]

          remPrL                        = trPP "REM" (filter (`elemOf` remPrIdSet) prL ++ [ PredOcc (prvnPred n) i | (i,n) <- fmToList . prvgIdNdMp $ g', i `elementOf` remArgPrIdSet])

prfPreds :: UID -> FIEnv -> [PredOcc] -> (CBindLMap,CSubst,[PredOcc],[CExpr],[Err])
prfPreds u env prL
  =  let  env'                          = trPP "ENV" env
          prL'                          = prL
          (g,prvnErrs)                  = trm "PROVEN" (\(x,_) -> pp x) (prfPredsToProvenGraph u env' prL')
          (g',gOr)                      = prfPredsPruneProvenGraph prL' g
          overl                         = [ (pr,map (\e -> case lookupFM (prvgIdNdMp gOr) e of {Just (ProvenAnd _ _ _ ev) -> ev; _ -> CExpr_Hole e}) es)
                                          | (ProvenOr pr es _) <- eltsFM (prvgIdNdMp gOr)
                                          ]
          (cbindLMap,csubst,remPrIdSet)
                                        = prvgCode prL' (trPP "PRUNE" g')
          elemOf p s                    = poId p `elementOf` s
          remPrL                        = trPP "REM" [ PredOcc p i | (i,ProvenArg p _) <- fmToList . prvgIdNdMp $ (trPP "PRUNE2" g') ]
     in   ( cbindLMap,csubst,remPrL,map (\po -> CExpr_Hole . poId $ po) prL
          , (if null overl then [] else [Err_OverlapPreds overl]) ++ prvnErrs
          )

%%[9
matchRule :: UID -> Pred -> Rule -> Maybe ([PredOcc],CExpr,PredOccId,ProofCost)
matchRule u pr r
  =  let  (_,u1,u2,u3)   = mkNewLevUID3 u
          (rTy,_)        = tyInst1Quants u1 instCoConst (rulRuleTy r)
          (us,vs)        = mkNewUIDTyVarL (tyArrowArity rTy) u2
          fo             = fitsIn (predFIOpts {fioDontBind = ftv pr}) emptyFE u3 rTy (vs `mkTyArrow` Ty_Pred pr)
     in   if foHasErrs fo
          then Nothing
          else Just  ( zipWith PredOcc (map tyPred . tyArrowArgs . foTy $ fo) us
                     , rulMkEvid r (map CExpr_Hole us)
                     , rulId r, rulCost r
                     )
%%]

%%[9
prvgAddOrig :: UID -> Pred -> ProvenGraph -> ProvenGraph
prvgAddOrig uid pr g = g {prvgPrOrigIdMp = addToFM_C (flip (++)) (prvgPrOrigIdMp g) pr [uid]}

prfOneStepClass :: FIEnv -> Pred -> UID -> ProofState -> ProofState
prfOneStepClass env pr@(Pred_Class t) prUid st@(ProofState g@(ProvenGraph i2n p2i p2oi) u toProof origToProof _)
  =   let  isInOrig             = pr `elem` origToProof
           nm                   = tyAppFunConNm t
           mkNdFail cost uid    = ProvenArg pr cost
           ndFail               = mkNdFail (if isInOrig then CostInt 1 else CostInt costALot) prUid
      in   case gamLookupAll nm (fePrElimGam env) of
             pegis@(_:_)
                 ->  let  (u',u1,u2)    = mkNewLevUID2 u
                          rules         = concat . zipWith (\lev pegi -> map (\r -> r {rulCost = rulCost r `costAdd` CostInt (lev*10)}) (pegiRuleL pegi)) [0..] $ pegis
                          ruleMatches   = catMaybes . zipWith (\u r -> matchRule u pr r) (mkNewUIDL (length rules) u1) $ rules
                          costOfOr      = if isInOrig then CostInt (-costALot) else CostInt 0 
                          (g',newPr)
                             = case ruleMatches of
                                   [] ->  (prvgAddPrNd pr [prUid] ndFail g,[])
                                   ms ->  let  orUids@(uidFail:uidRest) = mkNewUIDL (length ms + 1) u2
                                          in   foldr
                                                   (\(uid,m@(prOccL,evid,rid,cost)) (g,newPr)
                                                      -> let hasNoPre   =  null prOccL
                                                             addOrig    =  if hasNoPre then prvgAddOrig rid pr else id
                                                             prf        =  ProvenAnd pr (map poId prOccL)
                                                                             (if isInOrig && hasNoPre then CostAvailImpl (costCost cost) else cost) evid
                                                         in  (addOrig . prvgAddNd uid prf $ g,prOccL ++ newPr)
                                                   )
                                                   (prvgAddPrNd pr [prUid] (ProvenOr pr orUids costOfOr)
                                                      (prvgAddNd uidFail (mkNdFail (CostInt costALot) uidFail) g)
                                                   ,[])
                                                   (zip uidRest ms)
                     in   st {prfsUniq = u', prfsProvenGraph = g', prfsPredsToProve = newPr ++ toProof}
             []  ->  st {prfsProvenGraph = prvgAddPrNd pr [prUid] ndFail g}
%%]

%%[10
prfOneStepLacks :: FIEnv -> Pred -> UID -> ProofState -> ProofState
prfOneStepLacks env pr@(Pred_Lacks r l) prUid st@(ProofState g@(ProvenGraph i2n _ _) u toProof _ errs)
  =  let  zeroCost = CostInt 0
     in   case tyRowExtr l r of
            Just _ ->  st {prfsErrL = [Err_TooManyRowLabels [l] r] ++ errs}
            _      ->  let  (row,exts) = tyRowExts r
                            offset = tyExtsOffset l . tyRowCanonOrder $ exts
                       in   case row of
                              Ty_Var _ _ 
                                | null exts ->  case gamLookupAll (predMatchNm pr) (fePrElimGam env) of  
                                                  pegis@(_:_) | isJust mbMatch
                                                      -> fromJust mbMatch
                                                      where    (u',u1,u2)    = mkNewLevUID2 u
                                                               rules         = concat . map pegiRuleL $ pegis
                                                               ruleMatches   = catMaybes . zipWith (\u r -> matchRule u pr r) (mkNewUIDL (length rules) u1) $ rules
                                                               mbMatch
                                                                 =  case ruleMatches of
                                                                      [] ->  Nothing
                                                                      ((_,evid,rid,cost):_)
                                                                         ->  let  prf = ProvenAnd pr [] cost evid
                                                                                  g'  = prvgAddOrig rid pr . prvgAddNd prUid prf $ g
                                                                             in   Just (st {prfsProvenGraph = g', prfsUniq = u'})
                                                  []  ->  st {prfsProvenGraph = prvgAddPrNd pr [prUid] (ProvenArg pr zeroCost) g}
                                | otherwise ->  let  (u',u2) = mkNewUID u
                                                     newPr = PredOcc (Pred_Lacks row l) u2
                                                     g2 = prvgAddPrNd pr [prUid] (ProvenAnd pr [u2] zeroCost (CExpr_Hole u2 `mkCExprAddInt` offset)) g
                                                in   st {prfsProvenGraph = g2, prfsUniq = u', prfsPredsToProve = newPr : toProof}
                              _             ->  let  g2 = prvgAddPrNd pr [prUid] (ProvenAnd pr [] zeroCost (CExpr_Int offset)) g
                                                in   st {prfsProvenGraph = g2}
%%]

%%[9
prfOneStep :: FIEnv -> PredOcc -> ProofState -> ProofState
prfOneStep env (PredOcc pr prUid) st@(ProofState g@(ProvenGraph _ p2i _) _ _ _ _)
  =  case lookupFM p2i pr of
        Just uidL | prUid `notElem` uidL
          ->  let  uid  = last uidL
                   nd   = ProvenShare pr uid
              in   st {prfsProvenGraph = prvgAddPrNd pr (prUid : uidL) nd g}
        Nothing
          ->  case pr of
                Pred_Class _    -> prfOneStepClass env pr prUid st
%%]

%%[10
                Pred_Lacks _ _  -> prfOneStepLacks env pr prUid st
%%]

%%[11
                _               -> st
%%]

%%[9
        _ ->  st
%%]

%%[9
prfPredsToProvenGraph :: UID -> FIEnv -> [PredOcc] -> (ProvenGraph,[Err])
prfPredsToProvenGraph u env prL
  =  let  initState = ProofState
                        (ProvenGraph emptyFM emptyFM
                            (foldr (\p m -> addToFM_C (++) m (poPr p) [poId p]) (emptyFM) prL))
                        u prL (map poPr prL) []
          resolve st@(ProofState _ _ (pr:prL) _ _)
            =  let  st' = prfOneStep env pr (st {prfsPredsToProve = prL})
               in   resolve st'
          resolve st@(ProofState _ _ [] _ _) = st
          prvnState = resolve initState
     in   (prfsProvenGraph prvnState, prfsErrL prvnState)
%%]

%%[9
prfPredsPruneProvenGraph :: [PredOcc] -> ProvenGraph -> (ProvenGraph,ProvenGraph)
prfPredsPruneProvenGraph prL (ProvenGraph i2n p2i p2oi)
  =  let  costOf uid costMp gPrune
            =  case lookupFM costMp uid of
                 Just (Just c)  -> (uid,c,costMp,gPrune)
                 Just (Nothing) -> (uid,CostInt costALot,costMp,gPrune)
                 Nothing
                   ->  let  prvgAddPrevPrNd pr uid prf g
                              =  let  otherUids = maybe [] id (lookupFM p2i pr)
                                 in   prvgAddPrNd pr (uid : otherUids) prf g
                            costMp' = addToFM costMp uid Nothing
                       in   case fromJust (lookupFM i2n uid) of
                                 ProvenAnd pr es c ev
                                   ->  let  (cs,cm,gp)          = costOfL es costMp' gPrune
                                            c'                  = foldr costAdd c (map snd cs)
                                            cm'                 = addToFM cm uid (Just c')
                                            gp'                 = prvgAddPrevPrNd pr uid (ProvenAnd pr (map fst cs) c' ev) gp
                                       in   (uid,c',cm',gp')
                                 ProvenOr pr es c
                                   ->  let  (cs,cm,gp)          = costOfL es costMp' gPrune
                                            alts@((_,calt):_)   = head (groupSortOn snd cs)
                                            c'                  = c `costAdd` calt
                                            (uid',gp',c'')
                                              = case alts of
                                                    [(uida,_)]  -> (uida,prvgAddPrUids pr [uid] gp,calt)
                                                    _           -> (uid,prvgAddNd uid (ProvenOr pr (map fst alts) c') gp,c')
                                            cm'                 = addToFM (delFromFM cm uid) uid' (Just c'')
                                       in   (uid',c',cm',gp')
                                 ProvenShare pr e
                                   ->  let  (uid',c,cm,gp)      = costOf e costMp' gPrune
                                            gp'                 = prvgAddPrUids pr [uid] gp
                                       in   (uid',c,delFromFM cm uid,gp')
                                 prf@(ProvenArg pr c)
                                   ->  let  cm                  = addToFM costMp' uid (Just c)
                                            gp                  = prvgAddPrevPrNd pr uid prf gPrune
                                       in   (uid,c,delFromFM cm uid,gp)
          costOfL uidL costMp gPrune
            =  foldr  (\uid (cs,cm,g) ->  let  (uid',c,cm',g') = costOf uid cm g
                                          in   ((uid',c):cs,cm',g'))
                      ([],costMp,gPrune) uidL
          onlyReachables uidL g@(ProvenGraph i2n _ _)
            =  let  reachableUIDs = prvgReachableFrom g uidL
               in   g { prvgIdNdMp  = filterFM (\uid _ -> uid `elementOf` reachableUIDs) i2n }
          onlyOr g@(ProvenGraph i2n _ _)
            =  onlyReachables [ uid | (uid,ProvenOr _ _ _) <- fmToList i2n ] g
          (cs,_,gPrune) = costOfL (map poId prL) emptyFM (ProvenGraph emptyFM emptyFM p2oi)
     in   (prvgBackToOrig . onlyReachables (map fst cs) $ gPrune, onlyOr gPrune)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Retrieving evidence type for predicate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[9
fitPredToEvid :: UID -> Ty -> PrIntroGam -> FIOut
fitPredToEvid u prTy g
  =  case prTy of
       Ty_Any -> emptyFO
       _ ->  case gamLookup (tyPredMatchNm prTy) g of
               Just pigi
                 -> let (u',u1) = mkNewUID u
                        fo = fitsIn predFIOpts emptyFE u (pigiPrToEvidTy pigi) ([prTy] `mkTyArrow` mkTyVar u1)
                    in  fo {foTy = snd (tyArrowArgRes (foTy fo))}
               _ -> emptyFO {foErrL = [Err_NamesNotIntrod [tyPredMatchNm prTy]]}
%%]
