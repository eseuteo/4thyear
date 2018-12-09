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
s "x" = 1
s "y" = 6
s  _  = 0

s1 :: State
s1 "x" = 3
s1 "y" = 1
s1 "z" = 7
s1  _  = 0

showState :: State -> [Var] -> [String]
showState s [] = []
showState s (x:xs) = (x ++ " -> " ++ (show (s x))) : (showState s xs) 

-- | Test your function with HUnit.

testShowState :: Test
testShowState = test [  "Bindings in [] for state s" ~: [] ~=? showState s [],
                        "Bindings in [\"x\"] for state s" ~: ["x -> 1"] ~=? showState s ["x"],
                        "Bindings in [\"x\", \"y\"] for state s" ~: ["x -> 1", "y -> 6"] ~=? showState s ["x", "y"],
                        "Bindings in [\"x\", \"y\"] for state s1" ~: ["x -> 3", "y -> 1"] ~=? showState s1 ["x", "y"]]


-- | Exercise 1.2
-- | Define a function 'fvStm' that returns the free variables of a WHILE
-- | statement. For example:
-- |
-- | fvStm factorial = ["y","x"]
-- |
-- | Note: the order of appearance is not relevant, but there should not be
-- | duplicates.

fvStm :: Stm -> [Var]
fvStm (Ass v a)         = nub $ v : (fvAexp a)
fvStm (Skip)            = []
fvStm (Comp st1 st2)    = nub $ (fvStm st1) ++ (fvStm st2)
fvStm (If b st1 st2)    = nub $ (fvBexp b) ++ (fvStm st1) ++ (fvStm st2)
fvStm (While b st)      = nub $ (fvBexp b) ++ (fvStm st)
fvStm (Repeat st b)     = nub $ (fvStm st) ++ (fvBexp b)
fvStm (For v a1 a2 st)  = nub $ v : (fvAexp a1) ++ (fvAexp a2) ++ (fvStm st)

-- | Test your function with HUnit. Beware the order or appearance.

-- First, some statements for testing "fvStm" are created:

st1 :: Stm
st1 = Ass "x" (N 7)

st2 :: Stm
st2 = Skip

st3 :: Stm
st3 = Comp (Ass "y" (Mult (N 3) (V "x"))) (Skip)

st4 :: Stm
st4 = If (Eq (V "x") (N 10)) (Ass ("x") (Add (V "x") (N 1))) (Skip)

st5 :: Stm
st5 = While (Le (V "x") (N 100)) (Ass "x" (Add (V "x") (N 1)))

-- Then, the testing:

testFvStm :: Test
testFvStm = test [  "Free variables in st1" ~: ["x"] ~=? fvStm st1,
                    "Free variables in st2" ~: [] ~=? fvStm st2,
                    "Free variables in st3" ~: ["y", "x"] ~=? fvStm st3,
                    "Free variables in st4" ~: ["x"] ~=? fvStm st4,
                    "Free variables in st5" ~: ["x"] ~=? fvStm st5]


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

testShowFinalState :: Test
testShowFinalState = test [ "Final state of <st1, s>"       ~: ["x -> 7"] ~=? showFinalState st1 s,
                            "Final state of <st2, s>"       ~: [] ~=? showFinalState st2 s,
                            "Final state of <st3, s1>"      ~: ["y -> 9", "x -> 3"] ~=? showFinalState st3 s1,
                            "Final state of <st4, s>"       ~: ["x -> 1"] ~=? showFinalState st4 s,
                            "Final state of <st5, s1>"      ~: ["x -> 101"] ~=? showFinalState st5 s1,
                            "Final state of <factorial, s>" ~: ["y -> 1", "x -> 1"] ~=? showFinalState factorial s]

-- |----------------------------------------------------------------------
-- | Exercise 2
-- |----------------------------------------------------------------------
-- | Write a program in WHILE to compute z = x^y and check it by obtaining a
-- | number of final states.

power :: Stm -- WHILE statement to compute z = x^y
power = Comp
            (Ass "z" (N 1))
            (While (Neg (Eq (V "y") (N 0))) 
                (Comp
                    (Ass "z" (Mult (V "z") (V "x"))) 
                    (Ass "y" (Sub (V "y") (N 1)))))

-- | Test your function with HUnit. Inspect the final states of at least
-- | four different executions.

s01 :: State
s01 "x" =  2
s01 "y" =  0
s01 _   =  0

s02 :: State
s02 "x" =  3
s02 "y" =  1
s02 _   =  0

s03 :: State
s03 "x" =  5
s03 "y" =  5
s03 _   =  0

s04 :: State
s04 "x" =  10
s04 "y" =  10
s04 _   =  0

s05 :: State
s05 "x" = 32
s05 "y" = 5
s05 _   = 0

testPower :: Test
testPower = test ["Final state for 2^0" ~: ["z -> 1", "y -> 0", "x -> 2"] ~=? showFinalState power s01,
                  "Final state for 3^1" ~: ["z -> 3", "y -> 0", "x -> 3"] ~=? showFinalState power s02,
                  "Final state for 5^5" ~: ["z -> 3125", "y -> 0", "x -> 5"] ~=? showFinalState power s03,
                  "Final state for 10^10" ~: ["z -> 10000000000", "y -> 0", "x -> 10"] ~=? showFinalState power s04,
                  "Final state for 32^5" ~: ["z -> 33554432","y -> 0","x -> 32"] ~=? showFinalState power s05]

-- |----------------------------------------------------------------------
-- | Exercise 3
-- |----------------------------------------------------------------------
-- | The WHILE language can be extended with a 'repeat S until b' construct.

-- | Exercise 3.1
-- | Define the natural semantics of this new construct. You are not allowed
-- | to rely on the 'while b do S' statement.

{- Formal definition of 'repeat S until b'

                        <S, s> -> s'  <repeat S until b, s'> -> s''
        [repeat-ff]  -------------------------------------------------   if B[b]s' = ff
                                <repeat S until b, s> -> s''

                                <S, s> -> s'
        [repeat-tt]  ---------------------------------   if B[b]s' = tt
                        <repeat S until b, s> -> s'
                       
-}

-- | Extend  the definitions of  data type 'Stm' (in  module While.hs)
-- |  and  'nsStm'  (in  module NaturalSemantics.hs)  to  include  the
-- | 'repeat  S until b' construct.  Write a couple of  WHILE programs
-- | that use the 'repeat' statement and test your functions with HUnit.

stm1 :: Stm
stm1 =  (Repeat (Ass "x" (Add (V "x") (N 1))) (Eq (V "y") (N 0)))

stm2 :: Stm
stm2 =  (Repeat (Ass "x" (Add (V "x") (N 1))) (Eq (V "x") (N 6)))

modRepeat :: Stm -- WHILE statement to compute z = x % y, where x >= y
modRepeat = Comp 
                (If (Le (V "x") (V "y")) 
                (Comp (Comp 
                (Ass "z" (V "x")) 
                (Ass "x" (V "y"))) 
                (Ass "y" (V "z")))
                Skip)
                (Comp
                    (Repeat 
                        (Ass "x" (Sub (V "x") (V "y")))
                        (Neg (Le (V "y") (V "x"))))
                    (Ass "z" (V "x")))
                    
testRepeatUntil :: Test
testRepeatUntil = test ["Final state of <stm1, s01>" ~: ["x -> 3", "y -> 0"] ~=? showFinalState stm1 s01,
                        "Final state of <stm2, s01>" ~: ["x -> 6"] ~=? showFinalState stm2 s01,
                        "Final state of <modRepeat, s05>" ~: ["x -> 2", "y -> 5", "z -> 2"] ~=? showFinalState modRepeat s05]

-- |----------------------------------------------------------------------
-- | Exercise 4
-- |----------------------------------------------------------------------
-- | The WHILE language can be extended with a 'for x:= a1 to a2 do S'
-- | construct.

-- | Exercise 4.1
-- | Define the natural semantics of this new construct. You are not allowed
-- | to rely on the 'while b do S' or the 'repeat S until b' statements.

{- Formal definition of 'for x:= a1 to a2 do S'

                        <x := a1, s0> -> s1    <S, s1> -> s2    <for x := (A[x]s2 + 1) to a2 do S, s2> -> s3 
        [for-ff]   -------------------------------------------------------------------------------------------- if B[Le (V x) a2] s1 = tt
                                            <for x := a1 to a2 do S, s0> -> s3

                                <x := a1, s0> -> s1 
        [for-tt]   ------------------------------------------- if B[Le (V x) a2] s1 = ff
                        <for x := a1 to a2 do S, s0> -> s1
-}

-- Some remarks regarding our implementation of the for loop:
--      - The condition for leaving the loop is for the iterated variable to be greater than a2
--      - No checks regarding changing the iterated value are done

-- | Extend  the definitions of  data type 'Stm' (in  module While.hs)
-- | and  'nsStm'  (in  module NaturalSemantics.hs)  to  include  the
-- | 'for x:= a1 to a2 do S' construct.  Write a couple of  WHILE programs
-- | that use the 'for' statement and test your functions with HUnit.

sumFor :: Stm -- WHILE program for computing summatory
sumFor =    Comp 
                (Ass "z" (N 0)) 
                (For "x" (N 0) (V "y")
                    (Ass "z" (Add (V "z") (V "x"))))

sumForModX :: Stm -- WHILE program with modification of iterated variable
sumForModX =    Comp 
                (Ass "z" (N 2)) 
                (For "x" (N 0) (V "y")
                    (Ass "x" (Add (V "z") (V "x"))))

sumNestedFor :: Stm -- WHILE program with nested for
sumNestedFor =    Comp 
                (Ass "z" (N 0)) 
                (For "x" (N 1) (V "y")
                    (For "w" (N 1) (V "y")
                        (Ass "z" (Add (V "z") (N 1)))))


testFor :: Test
testFor = test ["Final state of <sumFor, s03>" ~: ["z -> 15","x -> 6","y -> 5"] ~=? showFinalState sumFor s03,
                "Final state of <sumForModX, s01>" ~: ["z -> 2","x -> 3","y -> 0"] ~=? showFinalState sumForModX s01,
                "Final state of <sumNestedFor, s04>" ~: ["z -> 100","x -> 11","y -> 10","w -> 11"] ~=? showFinalState sumNestedFor s04,
                "Final state of <sumNestedFor, s05>" ~: ["z -> 25","x -> 6","y -> 5","w -> 6"] ~=? showFinalState sumNestedFor s05]

-- |----------------------------------------------------------------------
-- | Exercise 5
-- |----------------------------------------------------------------------

-- | Define the semantics of arithmetic expressions (Aexp) by means of
-- | natural semantics. To that end, define an algebraic datatype 'ConfigAexp'
-- | to represent the configurations, and a function 'nsAexp' to represent
-- | the transition relation.

-- representation of configurations for Aexp, (replace TODO by appropriate
-- data definition)

data ConfigAExp = InterAexp Aexp State
                | FinalAexp Z

-- representation of the transition relation <A, s> -> z

nsAexp :: ConfigAExp -> ConfigAExp

nsAexp (InterAexp (N n) s) = FinalAexp n

nsAexp (InterAexp (V v) s) = FinalAexp (s v)

nsAexp (InterAexp (Add a1 a2) s) = FinalAexp z
    where 
        z = z1 + z2
        FinalAexp z1 = nsAexp (InterAexp a1 s)
        FinalAexp z2 = nsAexp (InterAexp a2 s)  

nsAexp (InterAexp (Sub a1 a2) s) = FinalAexp z
    where
        z = z1 - z2
        FinalAexp z1 = nsAexp (InterAexp a1 s)
        FinalAexp z2 = nsAexp (InterAexp a2 s)

nsAexp (InterAexp (Mult a1 a2) s) = FinalAexp z
    where
        z = z1 * z2
        FinalAexp z1 = nsAexp (InterAexp a1 s)
        FinalAexp z2 = nsAexp (InterAexp a2 s)

-- | Test your function with HUnit. Inspect the final states of at least
-- | four different evaluations.

-- Showing value of a ConfigAExp
showAexpVal :: ConfigAExp -> Z
showAexpVal (InterAexp aexp state) = error "showAexpVal: not a final configuration"
showAexpVal (FinalAexp z) = z

-- A few ConfigAexp
cea1 :: ConfigAExp
cea1 = InterAexp (N 0) s01

cea2 :: ConfigAExp
cea2 = InterAexp (V "x") s02

cea3 :: ConfigAExp
cea3 = InterAexp (Mult (N 2) (V "x")) s03

cea4 :: ConfigAExp
cea4 = InterAexp (Add (Mult (N 2) (V "x")) (Sub (V "x") (Mult (N 2) (V "y")))) s04

cea5 :: ConfigAExp
cea5 = InterAexp (Mult (Add (Add (V "x") (V "y")) (V "z")) (V "z")) s05

-- | Test your function with HUnit. Inspect the final states of at least
-- | four different evaluations.

testNsAexp :: Test
testNsAexp = test [     "Value of (N 0) in state []" ~: 0 ~=? (showAexpVal $ nsAexp cea1),
                        "Value ea2 st1" ~: 3 ~=? (showAexpVal $ nsAexp cea2),
                        "Value ea3 st1" ~: 10 ~=? (showAexpVal $ nsAexp cea3),
                        "Value ea4 st1" ~: 10 ~=? (showAexpVal $ nsAexp cea4),
                        "Value ea5 st1" ~: 0 ~=? (showAexpVal $ nsAexp cea5)]

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

nsDeriv ss@(Ass v aexp) s = (AssNS (config :-->: s'))
    where 
        s' = sNs ss s
        config = Inter ss s

nsDeriv ss@(Skip) s = (SkipNS (config :-->: s'))
    where
        s' = sNs ss s
        config = Inter ss s

nsDeriv ss@(Comp ss1 ss2) s = (CompNS (config :-->: s'') (nsDeriv ss1 s) (nsDeriv ss2 s'))
    where
        s'' = sNs ss s
        s' = sNs ss1 s
        config = Inter ss s

nsDeriv ss@(If bexp ss1 ss2) s 
    | bVal bexp s   = (IfTTNS (config :-->: s') (nsDeriv ss1 s))
    | otherwise     = (IfFFNS (config :-->: s') (nsDeriv ss2 s))
    where
        s' = sNs ss s
        config = Inter ss s

nsDeriv ss@(While bexp ss1) s
    | bVal bexp s   = (WhileTTNS (config :-->: s') (nsDeriv ss1 s) (nsDeriv ss s''))
    | otherwise     = (WhileFFNS (config :-->: s))
    where
        s' = sNs ss s
        s'' = sNs ss1 s
        config = Inter ss s

-- Some programs for testing ---------------------------------------------------

swap :: Stm
swap =  Comp (Comp (Ass "z" (V "x")) (Ass "x" (V "y"))) (Ass "y" (V "z"))

comp :: Stm
comp = Comp (Ass "z" (V "x")) (Ass "y" (V "z"))

ifelse :: Stm
ifelse = If (Le (V "x") (N 5)) (Ass "y" (N 10)) (Ass "y" (N 20))

sSwap :: State
sSwap "x" = 5
sSwap "y" = 7
sSwap _   = 0

--------------------------------------------------------------------------------

-- Show derivation tree
ioDerivation :: DerivTree -> IO ()
ioDerivation dt = io $ showDerivation dt

io :: String -> IO ()
io st = putStr ("\n\n"++st++"\n\n")
--------------------------------------------------------------------------------

showDerivation :: DerivTree -> String
showDerivation (AssNS (Inter stm s :-->: s')) = str
  where
    str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
          "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "] )"]

showDerivation (SkipNS (Inter stm s :-->: s')) =  str
  where
    str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
          "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "] )"]

showDerivation (CompNS (Inter stm s :-->: s') (d1) (d2)) = str
  where
    str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
           "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "]","\n",
           (showDerivation d1) ++ "\n", (showDerivation d2), " )"]

showDerivation (IfFFNS (Inter stm s :-->: s') (d1)) = str
  where
    str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
           "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "]","\n",
           (showDerivation d1) ++ " )"]

showDerivation (IfTTNS (Inter stm s :-->: s') (d1)) = str
  where
    str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
           "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "]","\n",
           (showDerivation d1) ++ " )"]

showDerivation (WhileTTNS (Inter stm s :-->: s') (d1) (d2)) = str
    where
        str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
            "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "]","\n",
            (showDerivation d1) ++ "\n", (showDerivation d2), " )"]

showDerivation (WhileFFNS (Inter stm s :-->: s')) =  str
    where
        str = concat ["( {", show stm, ", [ ", concatMap (++" ") $ showState s (fvStm stm),
            "]} ---> [ ", concatMap (++" ") $ showFinalState stm s, "] )"]
