\chapter{Improving substitution}
\label{ch:improving}
Until now we have only considered resolution of overloading by means of simplification.
In this chapter we extend the framework with improvement of constraint sets.


\section{Introduction}
We have shown how overloading can be resolved using CHRs and heuristics.
For example, proof obligations for type class qualifiers are simplified using instance declarations and the class hierarchy.
Besides simplification, constraint sets can also be solved by means of improvement~\citep{jones95improving}.
We give some examples to illustrate what improvement is and why we need it.

The first description of type classes~\citep{wadler89how} already mentions multi-parameter type classes.
However, multi-parameter type classes often lead to ambiguities and delayed detection of type errors.
As a solution, functional dependencies were introduced~\citep{jones00type}.
Functional dependencies allow the programmer to explicitly define relations between type class parameters.
The following standard example illustrates multi-parameter type classes and functional dependencies:
> class Coll c e | c -> e where
>   empty   :: c
>   insert  :: e -> c -> c
>   member  :: e -> c -> Bool
|Coll| is a type class for homogeneous collections, where |c| represents the type of the collection and |e| the type of the elements.
Assume that we use this type class without the functional dependency |c -> e|.
The first ambiguity occurs when using the function |empty| with type |(Coll c e) => c| because the type variable |e| occurs in the context but not in the type.
Second, the types assigned to |insert| and |member| are more liberal than we expect.
For example, consider the following function:
> test xs = insert 'c' (insert False xs)
The type |(Coll v1 Bool, Coll v1 Char) => v1 -> v1| is inferred for this function instead of the type error we expect for inserting two values of different types into the same collection.
With functional dependencies these problems can be solved because now we are able to specify that the type of the collection uniquely determines the type of the elements |(c -> e)|.
In other words, if we have two type class predicates |Coll c a| and |Coll c b|, then |a| must be equal to |b| because both constraints have type |c| as the first parameter.
The substitution |{a mapsto b}| is then an improvement for the type class predicate |Coll c a|.
Type checking the function |test| with the functional dependency result in the type error we expected because |Int| is not equal to |Bool|.

Functional dependencies are tricky because they can lead to inconsistencies and non-termination.
Therefore, Sulzmann et al.~\citep{fds-chrs, sulz06chrfd} formulate functional dependencies in terms of CHRs.
By making use of CHRs the authors prove that under some sufficient conditions, functional dependencies allow for sound, complete, and decidable type inference.
In this chapter we extend the framework with improvement and show how the proposed translation of Sulzmann et al. can be used.



\section{Definition of improvement}
Improving a set of qualifiers |P| results in an improving substitution |S|.
Improvement can be applied at any stage during the type inference process.
Intuitively, applying an improving substitution on a predicate set |P| replaces unsatisfiable predicates by satisfiable predicates.
Formally, this is defined in terms of satisfiable instances~\citep{jones95improving}: 
> (satisf P Q) = { SP | S insign Subst, Q entails SP }
The satisfiable instances of |P| with respect to |Q| are |(satisf P Q)|.
|S| {\it improves} |P| when |(satisf P Q)   ==   (satisf SP Q)|.
Compared to simplification, the evidence for improvement is the resulting substitution.
The difference is that often a choice can be made to apply a simplification step; however, the substitution generated by improvement is a fact that must be respected. 
This substitution must be applied to the predicates and types in the framework and in the compiler that uses this framework. 
For example, consider the following function for inserting two elements into a collection:
> insTwo x y c = insert x (insert [y] c)
The constraints |{Prove(Coll v1 v2), Prove(Coll v1 [v3])}| result from the two usages of |insert| in this function.
The inferred type for this function without the functional dependency would be |(Coll v1 v2, Coll v1 [v3]) => v2 -> v3 -> v1 -> v1|.
One of the two constraints is not satisfiable, because we cannot give evidence in the form of two functions inserting elements of different types into a collection of the same type.
Luckily, the functional dependency of the type class |Coll| results in the improving substitution |{v2 mapsto [v3]}|.
Applying the improving substitution on the earlier inferred type results in the type |Coll v1 [v3] => [v3] -> v3 -> v1 -> v1| for the function |insTwo|.



\section{Approach}
\begin{Figure}{Introduction and elimination of equality predicates}{eqpreds}
\begin{center}
~\\
\rulerRule{|(Elimination)|}{}
          {|S tau1 = S tau2|}
          {|S entails {tau1 == tau2}|}
\rulerRule{|(Introduction)|}{}
          {|(P ==> tau1 == tau2) insign Gamma ^^ ^^ ^^ S entails {tau1 == tau2}|}
          {|SQ entails SP|}          
          
~\\
~\\
\end{center}
\end{Figure}

We use the following approach to add improvement to our framework.
|Prove| constraints can be solved by simplification using the class hierarchy and using instance declarations.
We encode simplification in terms of CHRs generating every correct context reduction alternative.
Evidence in the form of a tree is generated from reduction alternatives for each |Prove| constraint.
Simplification is a method for solving |Prove| constraints.
We add improvement as an additional method for solving |Prove| constraints.
The evidence for solving a |Prove| constraint using improvement is a substitution instead of an evidence tree.

% TODO:: ik bedoel: geen enkele, en directly
No single |Prove| constraint can be solved using both simplification and improvement.
For example, the constraint |Prove (v1 == v2)| cannot be solved using simplification in the case of type class predicates. 
However, the improving substitution |{v1 mapsto v2}| is a solution for this constraint.
We do not make any assumption about the predicate language of the compiler that uses our framework.
However, in practice, the predicate language requires some form of equality predicates:

> pi   :=   tau1 == tau2
>      |    ...

The leftmost rule in Figure~\ref{eqpreds} specifies when an equality predicate is solved.
An equality predicate is solved when there is a substitution |S| where |S tau1| and |S tau2| are syntactically equivalent.
The compiler that uses our framework has to specify how a |Prove| constraint can be solved using improvement.
Usually, this will consist of a function unifying both components of the equality predicate (|tau1| and |tau2|).

The rightmost rule in Figure~\ref{eqpreds} specifies how equality predicates are introduced.
An equality predicate is introduced when it is implied by a matching CHR. 
In this way, the described translation for functional dependencies into CHRs~\citep{fds-chrs, sulz06chrfd} can easily be used in this framework.
We explain the translation using a well known example.
Consider the following class declaration for encoding a family of zip functions:

> class Zip a b c | c -> a, c -> b where  
>   zip :: [a] -> [b] -> c

A CHR is generated for each functional dependency:

> Prove(Zip a b c), Prove(Zip d e c)  ==>  Prove(a == d)
> Prove(Zip a b c), Prove(Zip d e c)  ==>  Prove(b == e)

The parameters |a| and |b| of the type class |Zip| are uniquely determined by |c|. 
Therefore, the fresh variables |d| and |e| are introduced in the CHRs for |a| and |b| respectively.
Proof obligation for equality predicates are generated when there are two |Prove| constraints in the constraint set mentioning the same type |c|.
CHRs are also generated for each instance of a class with functional dependencies:

> instance Zip a b [(a, b)] where 
>   zip  (x:xs)  (y:ys)  = (x,y) : zip xs ys 
>   zip  _       _       = []

The following CHRs are generated for the instance declaration in combination with the functional dependencies:

> Prove(Zip d e [(a, b)]) ==> Prove (d == a)
> Prove(Zip d e [(a, b)]) ==> Prove (e == b)

The type |[(a, b)]| in the instance declaration uniquely determines the type variables |a| and |b|.
Therefore, proof obligations for equality predicates are generated when a |Prove(Zip d e [(a, b)])| is matched in the constraint set.
The big advantage of translating functional dependencies into CHRs is that all improvements are made explicit.


On two points we deviate from the translation described by Sulzmann et al. 
The first deviation is that we use explicit |Prove| constraints.
Second, we do not propagate functional dependencies from superclasses.
For example, consider the following class declaration:

> class Zip a b c =>  C a b c

The following CHR is generated for the class declaration when using the translation described by Sulzmann et al:

> C a b c ==> Zip a b c

This CHR propagates the class hierarchy and thereby also the improvement CHRs of the superclasses.
For example, the constraint |(C v1 v2 [(Int, Bool)])| will also trigger the improvement CHRs generated for functional dependencies of type class |Zip|.
The result of applying the CHRs on the constraint |(C v1 v2 [(Int, Bool)])| is then:

> { C    v1 v2 [(Int, Bool)]
> , Zip  v1 v2 [(Int, Bool)]
> , v1 == Int
> , v2 == Bool   }

However, the class hierarchy is not propagated in the translation scheme we proposed.
This means that the CHRs generated for functional dependencies of class |pi| must also incorporate the functional dependencies of the superclasses of class |pi|.


\section{Implementation}
In this section we extend the framework to support improvement.
This extension does not influence the earlier described work on evidence translation and can be described independently.
However, there exist some interaction between simplification and improvement which we will describe at the end of this section.
First, we have to extend the state of the solver to store the list of CHRs describing the improvement relation. 

> data SolveState p s info = 
>   SolveSt  { rules        :: [CHR (Constraint p info) s]
>            , imprRules    :: [CHR (Constraint p info) s]
>            , ...
>            }

We could combine the lists of CHRs for improvement and simplification into one list. 
However, we separate those lists because improvement and simplification are two different steps and it is more clear to describe both relations separately.
Improvement can be applied at any stage during the type inference process with the following function:

> improve ::  (MonadState (SolveState p s info) m, Matchable p s, Ord info, Substitutable p v a) 
>             => (p -> Maybe a) -> m a  
> improve impr =
>   do  rls       <- gets imprRules
>       cnstrs    <- gets constraints  
>       let  equalities    = chrSolveList rls (Map.keys cnstrs)
>            (s, cnstrs')  = foldr (imprSubst impr) (mempty, cnstrs) equalities 
>       modifyConstraints (const cnstrs')
>       return s  

The above function is parametrized with the function |impr|.
This function parameter must be supplied by the compiler using this framework and is required to find an improvement for predicates.
The function |improve| first generates equality constraints by applying the CHRs for improvement.
Then, the function |imprSubst| is folded over the generated constraints.
This function constructs the improving substitution from the generated constraints using the |impr| function.
    
> imprSubst ::  (Ord p, Ord info, Substitutable p v a) => (p -> Maybe a) -> Constraint p info 
>               -> (a, Constraints  p info) -> (a, Constraints  p info)
> imprSubst impr  c@(Prove p)  (s, cs) = 
>                 case impr (substitute s p) of 
>                   Nothing  -> (s,               Map.insertWith (++) c [] cs)
>                   Just s'  -> (s' `mappend` s,  Map.delete c cs)
> imprSubst _     c             (s, cs) = (s,     Map.insertWith (++) c [] cs)

|Assume| constraints are solved by just inserting them into the constraint map.
Solving a |Prove| constraint consists of the following steps.
First, the improving substitution thus far is applied to predicate |p|.
Then, the function |impr| is applied to the result of applying the substitution.
The function |impr| tries to find an improving substitution for solving the constraint and gives the following result:
\begin{myitemize}
\item The function evaluates to |Nothing|. This means that this predicate cannot be solved using an improving substitution.
\item Otherwise, the function returns an improving substitution and thereby solving the predicate. 
\end{myitemize}
For example, consider the following function from the introduction again:
> test xs = insert 'c' (insert False xs)
The constraints |{Prove (Coll v1 Char), Prove (Coll v1 Bool)}| are generated for this function.
Solving these constraints with the CHR |Prove (Coll a b), Prove (Coll a c)  ==> Prove (b == c)| for improvement results in the constraint |Prove (Char == Bool)|.
There is no improving substitution for solving the constraint |Prove (Char == Bool)| so this constraint will remain unresolved and can be reported as an error.

It is possible that improvement can lead to new simplifications and the other way around.
For example, consider the following example program:

> class Coll c e | c -> e where
>   empty   :: c
>   insert  :: e -> c -> c
>   member  :: e -> c -> Bool
>
> instance Ord a => Coll [a] a where 
>   empty   = []
>   insert  = (:)
>   member  = elem
>
> replaceHead (_:xs) y = insert y xs 

The following CHRs are generated for this program:

> Prove (Coll a b), Prove (Coll a c)  ==>  Prove (b == c)    ^^   ^^     --   (C1)
> Prove (Coll [a] b)                  ==>  Prove (a == b)    ^^   ^^     --   (I1)
>
> Prove (Coll [a] a)                  ==>  Prove (Ord a)
>                                     ,    Reduction (Coll [a] a) "collList" [Ord a]  ^^ ^^ --   (I1)

The first two CHRs are improvement rules generated for the class and instance declaration respectively and the last CHR is a simplification CHR generated for the instance declaration for list collections.
The constraint |Prove (Coll [v1] v2)| is generated for the use of the overloaded function |insert| in the function |replaceHead|.
The following function applies simplification and improvement in a fix-point computation:

> fixImprove ::  (MonadState (SolveState p s info) m, Matchable p s, Ord info, Substitutable p v a)
>                => (p -> Maybe a) -> a -> m a
> fixImprove impr s = 
>   do  simplify
>       s' <- improve impr
>       if s' == mempty
>         then  return s
>         else  do  applySubstitution s'
>                   fixImprove impr (s `mappend` s')  
>
>
> applySubstitution ::  (MonadState (SolveState p s info) m, Ord p, Ord info, Substitutable p v > a)  
>                       =>  a -> m ()
> applySubstitution s = 
>   do  modifyConstraints  (Map.mapKeysWith (++)  (substitute s))
>       modifyEvidence     (Map.map               (substitute s))

First, the constraints are simplified.
In the current example no simplification CHR can be matched against the constraint |Prove (Coll [v1] v2)|.
Second, the constraints are improved which results for the current example in the substitution |{v2 mapsto v1}|.
The substitution is applied to the constraints and a recursive call to |fixImprove| takes place.
Now, a simplification can be applied to the substituted constraint |Prove (Coll [v1] v1)| resulting in the constraint |Prove(Ord v1)|.
No improvement rule can be matched against |Prove (Ord v1)| so the resulting substitution is empty and the fix-point is reached.

\section{Conclusion}
In this chapter we have given a short introduction to improvement and explained why improvement is useful.
For example, multi-parameter type classes are mostly useful in the context of functional dependencies.
Functional dependencies can be translated into CHRs~\citep{fds-chrs, sulz06chrfd}.
The advantage of this translation is that CHRs make the improvements generated by functional dependencies explicit.
We have explained how this translation can be used in our framework with some minor modifications.

The framework now supports improvement and simplification of qualified types. 
Thereby, we have given an implementation for the theoretical framework of Jones~\citep{jones92theory, jones95improving, jones95qualified}.
However, improvement is in some sense an ad-hoc extension of our framework.
We did not mention how improvement scales in combination with other extensions such as overlapping instances or local instances.
It would be nice to express improvements in the simplification graphs.
Improvements are then generated depending on the solution chosen by heuristics.
This would be an interesting research topic and we think our framework provides a solid basis for this research.
