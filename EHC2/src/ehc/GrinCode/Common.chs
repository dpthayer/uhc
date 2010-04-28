%%[0
%include lhs2TeX.fmt
%include afp.fmt
%%]
%%[(8 codegen grin) module {%{EH}GrinCode.Common}
%%]
%%[(8 codegen grin) import( qualified Data.Map as Map, qualified Data.Set as Set, Data.Array, Data.Maybe, Data.Monoid, Char(isDigit) )
%%]
%%[(8 codegen grin) import( {%{EH}Base.Common}, {%{EH}Base.Builtin} )
%%]
%%[(8 codegen grin) import( {%{EH}GrinCode} )
%%]
%%[(8 codegen grin) hs import(Debug.Trace)
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Special names                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(8 codegen grin) export(wildcardNm, wildcardNr, mainNr, getNr, throwTag, hsnMainFullProg, conName, evaluateNr, evaluateArgNr, diffMap)

wildcardNm = hsnFromString "_"
wildcardNr = HNmNr 0 (OrigLocal wildcardNm)

getNr :: HsName -> Int
getNr (HNmNr i _)      = i
getNr (HsName_Pos i)   = error $ "getNr tried on HNPos " ++ show i
getNr a                = error $ "getNr tried on " ++ show a

throwTag      =  GrTag_Fun (hsnFromString "rethrow")

%%[[8
hsnMainFullProg = hsnPrefix "fun0~" hsnMain
%%][99
hsnMainFullProg = hsnSuffix hsnMain "FullProg" -- should be: hsnUniqifyStr HsNameUniqifier_New "FullProg" hsnMain
%%]]

-- The fixed numbers for special functions.
mainNr     = HNmNr 1 (OrigFunc hsnMainFullProg)

evaluateNr    = HNmNr 3 (OrigFunc (hsnFromString "evaluate"))
evaluateArgNr = HNmNr 5 (OrigNone)

%%]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Abstract interpretation domain %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(8 codegen grin) export(Variable, AbstractNodes(..), AbstractValue(..), AbstractCall, AbstractCallList)
%%]

%%[(8 codegen grin).AbstractValue

type Variable = Int


data AbstractNodes
  = Nodes (Map.Map GrTag [Set.Set Variable])
    deriving (Eq, Ord)

data AbstractValue
  = AbsBottom
  | AbsBasic
  | AbsTags  (Set.Set GrTag)
  | AbsNodes AbstractNodes
  | AbsPtr   AbstractNodes    (Set.Set Variable) (Set.Set Variable)
  | AbsUnion (Map.Map GrTag  AbstractValue )
  | AbsError String
    deriving (Eq, Ord)

type AbstractCall
  = (Variable, [Maybe Variable])
  
type AbstractCallList
  = [AbstractCall]


instance Show AbstractNodes where
  show (Nodes ns) = show (Map.assocs ns)

instance Show AbstractValue where
    show av = case av of
                  AbsBottom   -> "BOT"
                  AbsBasic    -> "BAS"
                  AbsTags  ts -> "TAGS" ++ show (Set.elems ts)
                  AbsNodes an -> "NODS" ++ show an
                  AbsPtr   an vs ws -> "PTR"  ++ show an  ++ show vs ++ show ws
                  AbsUnion xs -> "UNION" ++ show (Map.assocs xs)
                  AbsError s  -> "ERR: " ++ s


limitIntersect (Just a) (Just b) = Just (Set.intersection a b)
limitIntersect Nothing  b        = b
limitIntersect a        _        = a


instance Monoid AbstractNodes where
   mempty = Nodes Map.empty
   mappend (Nodes an) (Nodes bn) = Nodes (Map.unionWith (zipWith Set.union) an bn)

instance Monoid AbstractValue where
    mempty                                  =  AbsBottom
    mappend  a                 AbsBottom    =  a
    mappend    AbsBottom    b               =  b
    mappend    AbsBasic        AbsBasic     =  AbsBasic
    mappend   (AbsTags  at)   (AbsTags  bt) =  AbsTags      (Set.union at bt)
    mappend   (AbsNodes an)   (AbsNodes bn) =  AbsNodes     (mappend an bn)
    mappend   (AbsPtr   an1 vs1 ws1)(AbsPtr an2 vs2 ws2) =  AbsPtr    (mappend an1 an2) (Set.union vs1 vs2) (Set.union ws1 ws2)
    mappend   (AbsUnion am)   (AbsUnion bm) =  AbsUnion     (Map.unionWith          mappend  am bm)
    mappend a@(AbsError _ ) _               =  a
    mappend _               b@(AbsError _ ) =  b
    mappend a               b               =  AbsError $ "Wrong variable usage: pointer, node or basic value mixed" 
                                                ++ "\n first = " ++ show a 
                                                ++ "\n second = " ++ show b


-- (Ord GrTag) is needed for (Ord AbstractValue) which is needed for Map.unionWith in mergeNodes


conNumber :: GrTag -> Int
-- Final tags first
conNumber (GrTag_Con _ _ _) = 1
conNumber (GrTag_PApp _ _)  = 2
conNumber GrTag_Rec         = 3
conNumber GrTag_Unboxed     = 4
-- "Hole" separates final tags from unevaluated tags (this fact is exploited Grin2Silly, for generating code for Reenter alternatives)
conNumber GrTag_Hole        = 7
-- Unevaluated tags last
conNumber (GrTag_Fun _)     = 8
conNumber (GrTag_App _)     = 9


conName :: GrTag -> HsName
conName (GrTag_App nm) = nm
conName (GrTag_Fun nm) = nm
conName (GrTag_PApp _ nm) = nm
conName (GrTag_Con _ _ nm) = nm

conInt :: GrTag -> Int
conInt (GrTag_PApp i _ ) = i
conInt (GrTag_Con _ i _ ) = i

instance Ord GrTag where
  compare t1 t2 = let x = conNumber t1
                      y = conNumber t2
                  in  case compare x y of 
                        EQ -> if  x >= 3 && x <= 7
                              then -- Rec/Unboxed/World/Any/Hole
                                   EQ
                              else -- App/Fun/PApp/Con, all have a name
                                   case cmpHsNameOnNm (conName t1) (conName t2) of
                                     EQ -> if  x >= 8
                                           then -- App/Fun
                                                EQ
                                           else -- Papp/Con, both have an int
                                                compare (conInt t1) (conInt t2)
                                     a  -> a
                        a  -> a


%%]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Abstract interpretation constraints     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(8 codegen grin) export(Equation(..), Equations, Limitation, Limitations, limitIntersect)

data Equation
  = IsBasic               Variable
  | IsTags                Variable  [GrTag]
  | IsPointer             Variable  GrTag [Maybe Variable]
  | IsConstruction        Variable  GrTag [Maybe Variable]       (Maybe Variable)
  | IsUpdate              Variable  Variable
  | IsEqual               Variable  Variable
  | IsSelection           Variable  Variable Int GrTag
  | IsEnumeration         Variable  Variable
  | IsEvaluation          Variable  Variable                     Variable
  | IsApplication         Variable  [Variable]                   Variable
  | IsFetch               Variable  Variable
    deriving (Show, Eq)


type Limitation
  = (Variable, [GrTag])

type Equations     = [Equation]
type Limitations   = [Limitation]

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Abstract interpretation result          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[(8 codegen grin) export(HptMap, getBaseEnvList, getEnvVar, absFetch, addEnvElems, addEnvNamedElems, getEnvSize, getTags, getNodes, isBottom, showHptMap, isPAppTag, isFinalTag, isApplyTag, filterTaggedNodes, getApplyNodeVars)

type HptMap  = Array Int AbstractValue

diffMap :: HptMap -> HptMap -> HptMap
diffMap h1 h2 
  | bounds h1 == bounds h2 = listArray (bounds h1) (zipWith diff (elems h1) (elems h2))
  | otherwise = error "woopsie"

nodeDiff :: AbstractNodes -> AbstractNodes -> Maybe AbstractNodes
nodeDiff (Nodes a) (Nodes b) = if Map.null c then Nothing else Just (Nodes c)
  where c = Map.differenceWith tagNodeDiff a b

tagNodeDiff :: [Set.Set Variable] -> [Set.Set Variable] -> Maybe [Set.Set Variable]
tagNodeDiff a b = if all Set.null c then Nothing else Just c
  where c = zipWith Set.difference a b

ptrDiff   (AbsPtr   an1 vs1 ws1) (AbsPtr an2 vs2 ws2) 
    = if (Set.null ws3 && Set.null vs3 && isNothing an3) then AbsBottom else AbsPtr (maybe (Nodes Map.empty) id an3) vs3 ws3
  where
  ws3 = Set.difference ws1 ws2
  vs3 = Set.difference vs1 vs2
  an3 = nodeDiff an1 an2

diff :: AbstractValue -> AbstractValue -> AbstractValue
diff    AbsBottom    b               =  AbsBottom
diff  a                 AbsBottom    =  a
diff    AbsBasic        AbsBasic     =  AbsBottom
diff   (AbsTags  at)   (AbsTags  bt) =  let rem = Set.difference at bt in
                                        if Set.null rem then AbsBottom else AbsTags rem
diff   (AbsNodes an)   (AbsNodes bn) =  maybe AbsBottom AbsNodes (nodeDiff an bn)
diff   ptr1@(AbsPtr _ _ _) ptr2@(AbsPtr _ _ _) 
                                     =  ptrDiff ptr1 ptr2
diff   (AbsUnion am)   (AbsUnion bm) =  AbsUnion (Map.differenceWith (\a b -> case diff a b of { AbsBottom -> Nothing; x -> Just x }) am bm)
diff a@(AbsError _ ) _               =  a
diff _               b@(AbsError _ ) =  b
diff a               b               =  AbsError $ "Wrong variable usage: pointer, node or basic value mixed" 
                                            ++ "\n first = " ++ show a 
                                            ++ "\n second = " ++ show b
                                                
showHptElem :: (Int,AbstractValue) -> String
showHptElem (n,v) = show n ++ ": " ++ show v

showHptMap :: HptMap -> String
showHptMap ae
  =  unlines (map showHptElem (assocs ae))

getBaseEnvList :: HptMap -> [(Int,AbstractValue)]
getBaseEnvList ae = assocs ae
     
getEnvVar :: HptMap -> Int -> AbstractValue
getEnvVar ae i  | snd (bounds ae) >= i = (ae ! i)
                | otherwise            = error ("getEnvVar: variable "++ show i ++ " not found") AbsBottom   -- AbsError $ "variable "++ show i ++ " not found"
                         

limit :: Maybe (Set.Set GrTag) -> AbstractValue -> AbstractValue
limit Nothing v = v
limit (Just tset) (AbsNodes (Nodes ns)) = AbsNodes (Nodes (Map.fromList (filter (validTag tset) (Map.toList ns))))
limit _ v = error ("limit applied to non-Node " ++ show v)

validTag ts (t@(GrTag_Con _ _ _) , _)  = Set.member t ts
validTag _  _                          = True



absFetchDirect :: HptMap -> Variable -> AbstractValue
absFetchDirect a i  = case getEnvVar a i of
                        AbsPtr an vs ws -> mconcat (AbsNodes an :  map (getEnvVar a) (Set.toList ws))
                        AbsBottom       -> AbsNodes (Nodes Map.empty)
                        av              -> error ("AbsFetchDirect i=" ++ show i ++ " av=" ++ show av)


absFetch :: HptMap -> HsName -> AbstractValue
absFetch a nm@(HNmNr i _) = case getEnvVar a i of
                             AbsPtr an vs ws -> mconcat (AbsNodes an :  map (absFetchDirect a) (Set.toList vs) ++ map (getEnvVar a) (Set.toList ws))   -- TODO: ++ inhoud van ws?
                             AbsBottom     -> AbsNodes (Nodes Map.empty)
                             AbsError s     -> error $ "analysis error absFetch: " ++ show a ++ s
                             AbsBasic       -> error $ "variable " ++ show i ++ " is a basic value"
                             AbsNodes _     -> error $ "variable " ++ show i ++ " is a node variable"
                             _              -> error $ "absFetch fails with nm = " ++ show nm
absFetch a x = error ("absFetch tried on " ++ show x)

getTags av = case av of
                 AbsTags  ts -> Just (Set.toList ts)
                 AbsBottom   -> Nothing
                 AbsNodes (Nodes n)  -> Just (map fst (Map.toAscList n))

getNodes av = case av of
                 AbsNodes (Nodes n)  -> Map.toAscList n
                 AbsBottom   -> []
                 AbsError s  -> error $ "analysis error getNodes2: " ++  s
                 _           -> error $ "not a node2: " ++ show av

isBottom av = case av of
                  AbsBottom   ->  True
                  AbsNodes n  ->  False -- Map.null n
                  AbsError s  ->  error $ "analysis error isBottom: " ++ s
                  otherwise   ->  False

addEnvElems :: HptMap -> [AbstractValue] -> HptMap
addEnvElems e vs
  =  let (low, high) = bounds e
         extra = length vs 
         e2    = listArray (low, high+extra) (elems e ++ vs)
     in e2

---------------------------------------------------------------------------------------------------------
--- Maybe should be replaced.
replaceAt :: Int -> a -> [a] -> [a]
replaceAt i a xs = case (i,xs) of
  (_,[]) -> error "cannot replace outside of list"
  (0,x:xs) -> a:xs 
  (_,x:xs) -> x: replaceAt (i-1) a xs
---------------------------------------------------------------------------------------------------------    
     
addEnvNamedElems :: HptMap -> [(Int,AbstractValue)] -> HptMap
addEnvNamedElems hpt vs
  = let (low, high) = bounds hpt
        extra = foldl (\i -> max i . fst) high vs - high
        e2 = listArray (low, high+extra) (foldl (flip $ uncurry replaceAt) (elems hpt ++ replicate extra AbsBottom) vs)
    in e2
     
getEnvSize :: HptMap -> Int
getEnvSize e  = let (low,high) = bounds e
                in  high-low+1

isPAppTag :: GrTag -> Bool
isPAppTag (GrTag_PApp _ _) = True
isPAppTag _                = False

isFinalTag :: GrTag -> Bool
isFinalTag  GrTag_Hole       = True
isFinalTag  GrTag_Unboxed    = True
isFinalTag (GrTag_PApp _ _)  = True
isFinalTag (GrTag_Con _ _ _) = True
isFinalTag _                 = False

isApplyTag (GrTag_App _)     = True
isApplyTag _                 = False


filterTaggedNodes :: (GrTag->Bool) -> AbstractValue -> AbstractValue
filterTaggedNodes p (AbsNodes (Nodes nodes)) = let newNodes = Map.filterWithKey (const . p) nodes
                                               in AbsNodes (Nodes newNodes)
filterTaggedNodes p av               = av

getApplyNodeVars :: AbstractValue -> [ Variable ]
getApplyNodeVars (AbsNodes (Nodes nodes)) = [ getNr nm  | (GrTag_App nm) <- Map.keys nodes ]
getApplyNodeVars _                = []

%%]
