{-|

Programming Languages
Fall 2018

Implementation in Haskell of the Natural Semantics described in Chapter 2 of
Nielson & Nielson, Semantics with Applications

Author: Ricardo Holthausen
        Salvador Carrillo Fuentes

-}

module Exercises02 where

import           Exercises01      (Update (..), fvAexp, fvBexp, update)
import           NaturalSemantics
import           Test.HUnit       hiding (State)
import           While
import           Data.List

-- |----------------------------------------------------------------------
-- | Exercise 1
-- |----------------------------------------------------------------------
-- | The function 'sNs' returns the final state of the execution of a
-- | WHILE statement 'st' from a given initial state 's'. For example:
-- |
-- |  sNs factorial sInit
-- |
-- | returns the final state:
-- |
-- |    s x = 1
-- |    s y = 6
-- |    s _ = 0
-- |
-- | Since a state is a function it cannot be printed thus you cannot
-- | add 'deriving Show' to the algebraic data type 'Config'.
-- | The goal of this exercise is to define a number of functions to
-- | "show" a state thus you can inspect the final state computed by the
-- | natural semantics of WHILE.

-- | Exercise 1.1
-- | Define a function 'showState' that given a state 's' and a list
-- | of variables 'vs' returns a list of strings showing the bindings
-- | of the variables mentioned in 'vs'. For example, for the state
-- | 's' above we get:
-- |
-- |    showState s ["x"] = ["x -> 1"]
-- |    showState s ["y"] = ["y -> 6"]
-- |    showState s ["x", "y"] = ["x -> 1", "y -> 6"]
-- |    showState s ["y", "z", "x"] = ["y -> 6", "z -> 0", "x -> 1"]

s :: State
s "x" = 2
s "y" = 10000
s  _  = 0

showState :: State -> [Var] -> [String]
showState s [] = []
showState s (x:xs) = (x ++ " -> " ++ (show (s x))) : (showState s xs) 

-- | Test your function with HUnit.


-- | Exercise 1.2
-- | Define a function 'fvStm' that returns the free variables of a WHILE
-- | statement. For example:
-- |
-- | fvStm factorial = ["y","x"]
-- |
-- | Note: the order of appearance is not relevant, but there should not be
-- | duplicates.

fvStm :: Stm -> [Var]
fvStm (Ass v a) = fvAexp a
fvStm (Skip) = []
fvStm (Comp st1 st2) = nub ((fvStm st1) ++ (fvStm st2))
fvStm (If b st1 st2) = nub ((fvStm st1) ++ (fvStm st2))
fvStm (While b st) = fvStm st

-- | Test your function with HUnit. Beware the order or appearance.


-- | Exercise 1.3
-- | Define a function 'showFinalState' that given a WHILE statement and a
-- | initial state returns a list of strings with the bindings of
-- | the free variables of the statement in the final state. For
-- | example:
-- |
-- |  showFinalState factorial sInit = ["y->6","x->1"]

showFinalState :: Stm -> State -> [String]
showFinalState st s = showState (sNs st s) (fvStm st)

-- | Test your function with HUnit. Beware the order or appearance.


-- |----------------------------------------------------------------------
-- | Exercise 2
-- |----------------------------------------------------------------------
-- | Write a program in WHILE to compute z = x^y and check it by obtaining a
-- | number of final states.

{-
z = 1;
while (y > 1) {
        z = z * x;
        y = y - 1;
}
-}

power :: Stm -- WHILE statement to compute z = x^y
power = Comp
            (Ass "z" (N 1))
            (While (Neg (Eq (V "y") (N 0))) 
                (Comp
                    (Ass "z" (Mult (V "z") (V "x"))) 
                    (Ass "y" (Sub (V "y") (N 1)))))

-- | Test your function with HUnit. Inspect the final states of at least
-- | four different executions.


-- |----------------------------------------------------------------------
-- | Exercise 3
-- |----------------------------------------------------------------------
-- | The WHILE language can be extended with a 'repeat S until b' construct.

-- | Exercise 3.1
-- | Define the natural semantics of this new construct. You are not allowed
-- | to rely on the 'while b do S' statement.

{- Formal definition of 'repeat S until b'


        [repeat-ff]  ------------------------------   ¿condition?




        [repeat-tt]  ------------------------------   ¿condition?


-}

-- | Extend  the definitions of  data type 'Stm' (in  module While.hs)
-- |  and  'nsStm'  (in  module NaturalSemantics.hs)  to  include  the
-- | 'repeat  S until b' construct.  Write a couple of  WHILE programs
-- | that use the 'repeat' statement and test your functions with HUnit.

-- |----------------------------------------------------------------------
-- | Exercise 4
-- |----------------------------------------------------------------------
-- | The WHILE language can be extended with a 'for x:= a1 to a2 do S'
-- | construct.

-- | Exercise 4.1
-- | Define the natural semantics of this new construct. You are not allowed
-- | to rely on the 'while b do S' or the 'repeat S until b' statements.

{- Formal definition of 'for x:= a1 to a2 do S'


-}

-- | Extend  the definitions of  data type 'Stm' (in  module While.hs)
-- | and  'nsStm'  (in  module NaturalSemantics.hs)  to  include  the
-- | 'for x:= a1 to a2 do S' construct.  Write a couple of  WHILE programs
-- | that use the 'for' statement and test your functions with HUnit.


-- |----------------------------------------------------------------------
-- | Exercise 5
-- |----------------------------------------------------------------------

-- | Define the semantics of arithmetic expressions (Aexp) by means of
-- | natural semantics. To that end, define an algebraic datatype 'ConfigAexp'
-- | to represent the configurations, and a function 'nsAexp' to represent
-- | the transition relation.

-- representation of configurations for Aexp, (replace TODO by appropriate
-- data definition)

data ConfigAExp = TODO

-- representation of the transition relation <A, s> -> s'

nsAexp :: Config -> Config
nsAexp = undefined

-- | Test your function with HUnit. Inspect the final states of at least
-- | four different evaluations.


-- |----------------------------------------------------------------------
-- | Exercise 6
-- |----------------------------------------------------------------------

-- | Given the algebraic data type 'DerivTree' to represent derivation trees
-- | of the natural semantics:

data Transition = Config :-->: State

data DerivTree = AssNS     Transition
               | SkipNS    Transition
               | CompNS    Transition DerivTree DerivTree
               | IfTTNS    Transition DerivTree
               | IfFFNS    Transition DerivTree
               | WhileTTNS Transition DerivTree DerivTree
               | WhileFFNS Transition

-- | and the function 'getFinalState' to access the final state of the root
-- | of a derivation tree:

getFinalState :: DerivTree -> State
getFinalState (AssNS  (_ :-->: s))         = s
getFinalState (SkipNS (_ :-->: s))         = s
getFinalState (CompNS (_ :-->: s) _ _ )    = s
getFinalState (IfTTNS (_ :-->: s) _ )      = s
getFinalState (IfFFNS (_ :-->: s) _ )      = s
getFinalState (WhileTTNS (_ :-->: s) _ _ ) = s
getFinalState (WhileFFNS (_ :-->: s))      = s

-- | Define a function 'nsDeriv' that given a WHILE statement 'st' and an
-- | initial state 's' returns corresponding derivation tree.

nsDeriv :: Stm -> State -> DerivTree
nsDeriv st s = undefined
