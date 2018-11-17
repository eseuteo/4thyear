{-|

Programming Languages
Fall 2018

Implementation in Haskell of the concepts covered in Chapter 1 of
Nielson & Nielson, Semantics with Applications

Authors:    Ricardo Holthausen
            Salvador Carrillo Fuentes

-}

module Exercises01 where

import           Test.HUnit hiding (State)
import           While
import           Data.List

-- |----------------------------------------------------------------------
-- | Exercise 1
-- |----------------------------------------------------------------------
-- | Given the algebraic data type 'Bin' for the binary numerals:

data Bit = O
         | I
         deriving (Show, Eq)

data Bin = MSB Bit
         | B Bin Bit
         deriving (Show, Eq)

-- | and the following values of type 'Bin':

zero :: Bin
zero = MSB O

one :: Bin
one = MSB I

three :: Bin
three = B (B (MSB O) I) I

six :: Bin
six = B (B (MSB I) I) O

-- | define a semantic function 'binVal' that associates
-- | a number (in the decimal system) to each binary numeral.

binVal :: Bin -> Z
binVal (MSB O) = 0
binVal (MSB I) = 1
binVal (B bin bit) = binVal (MSB bit) + 2 * binVal bin

-- | Test your function with HUnit.

testBinVal :: Test
testBinVal = test ["value of zero"  ~: 0 ~=? binVal zero,
                   "value of one"   ~: 1 ~=? binVal one,
                   "value of three" ~: 3 ~=? binVal three,
                   "value of six"   ~: 6 ~=? binVal six]

-- | Define a function 'foldBin' to fold a value of type 'Bin'

foldBin ::  (a -> Bit -> a) -> 
            (Bit -> a) -> 
            Bin -> a
foldBin b msb (MSB bit) = msb bit
foldBin b msb (B bin bit) = b (foldBin b msb bin) bit

-- | and use 'foldBin' to define a function 'binVal''  equivalent to 'binVal'.

binVal' :: Bin -> Integer
binVal' bin = foldBin sum val bin
    where
        val O = 0
        val I = 1
        sum n b = 2 * n + val b

-- | Test your function with HUnit.

testBinVal' :: Test
testBinVal' = test  ["value of zero"  ~: 0 ~=? binVal' zero,
                     "value of one"   ~: 1 ~=? binVal' one,
                     "value of three" ~: 3 ~=? binVal' three,
                     "value of six"   ~: 6 ~=? binVal' six]

-- | Define a function 'hammingWeight' that returns the number of ones occurring
-- | in a binary numeral.

hammingWeight :: Bin -> Integer
hammingWeight (MSB O) = 0
hammingWeight (MSB I) = 1
hammingWeight (B bin O) = 0 + hammingWeight bin
hammingWeight (B bin I) = 1 + hammingWeight bin

-- | and use 'foldBin' to define a function 'hammingWeight''  equivalent to 'hammingWeight'.

hammingWeight' :: Bin -> Integer
hammingWeight' bin = foldBin sum one bin
    where
        one I = 1
        one O = 0
        sum n b = n + one b

-- | Test your functions with HUnit.

testHammingWeight :: Test
testHammingWeight = test  ["value of zero"  ~: 0 ~=? hammingWeight zero,
                           "value of one"   ~: 1 ~=? hammingWeight one,
                           "value of three" ~: 2 ~=? hammingWeight three,
                           "value of six"   ~: 2 ~=? hammingWeight six]

testHammingWeight' :: Test
testHammingWeight' = test  ["value of zero"  ~: 0 ~=? hammingWeight' zero,
                            "value of one"   ~: 1 ~=? hammingWeight' one,
                            "value of three" ~: 2 ~=? hammingWeight' three,
                            "value of six"   ~: 2 ~=? hammingWeight' six]

-- | Define a function 'complement' that returns the complement of a binary numeral

complement :: Bin -> Bin
complement (MSB O)      = (MSB I)
complement (MSB I)      = (MSB O)
complement (B bin O)    = (B (complement bin) I)
complement (B bin I)    = (B (complement bin) O)

-- | and use 'foldBin' to define a function 'complement''  equivalent to 'complement'.

complement' :: Bin -> Bin
complement' bin = foldBin acum comp bin
    where
        comp O = (MSB I)
        comp I = (MSB O)
        acum bin b = (B bin (extract (comp b)))
            where
                extract (MSB x) = x  

-- | Test your functions with HUnit.

testComplement :: Test
testComplement = test  ["value of zero"  ~: MSB I ~=? complement zero,
                        "value of one"   ~: MSB O ~=? complement one,
                        "value of three" ~: B (B (MSB I) O) O ~=? complement three,
                        "value of six"   ~: B (B (MSB O) O) I ~=? complement six]

testComplement' :: Test
testComplement' = test  ["value of zero"  ~: MSB I ~=? complement' zero,
                        "value of one"   ~: MSB O ~=? complement' one,
                        "value of three" ~: B (B (MSB I) O) O ~=? complement' three,
                        "value of six"   ~: B (B (MSB O) O) I ~=? complement' six]

normalize :: Bin -> Bin
normalize (MSB x) = (MSB x)
normalize (B (MSB O) bit) = (MSB bit)
normalize (B bin bit)   | (normalize bin) == (MSB O) = (MSB bit)
                        | otherwise                  = (B (normalize bin) bit) 

-- | and use 'foldBin' to define a function 'normalize''  equivalent to 'normalize'.

normalize' :: Bin -> Bin
normalize' bin = foldBin acum norm bin
    where
        norm x = (MSB x)
        acum (MSB O) b = (MSB b)
        acum bin b = (B bin b)    

-- | Test your functions with HUnit.

testNormalize :: Test
testNormalize = test  ["value of zero"  ~: MSB O ~=? normalize zero,
                       "value of one"   ~: MSB I ~=? normalize one,
                       "value of three" ~: B (MSB I) I ~=? normalize three,
                       "value of six"   ~: B (B (MSB I) I) O ~=? normalize six,
                       "value of complement' six" ~: MSB I ~=? normalize (complement six)]

testNormalize' :: Test
testNormalize' = test  ["value of zero"  ~: MSB O ~=? normalize' zero,
                        "value of one"   ~: MSB I ~=? normalize' one,
                        "value of three" ~: B (MSB I) I ~=? normalize' three,
                        "value of six"   ~: B (B (MSB I) I) O ~=? normalize' six,
                        "value of complement' six" ~: MSB I ~=? normalize' (complement six)]

-- |----------------------------------------------------------------------
-- | Exercise 2
-- |----------------------------------------------------------------------
-- | Define the function 'fvAexp' that computes the set of free variables
-- | occurring in an arithmetic expression. Ensure that each free variable
-- | occurs once in the resulting list.

aExp0 :: Aexp
aExp0 = (V "x")

aExp1 :: Aexp
aExp1 = (Mult (V "x") (V "y"))

aExp2 :: Aexp
aExp2 = (Add aExp0 (Sub aExp1 (V "z")))

aExp3 :: Aexp
aExp3 = (Sub aExp2 (Add (V "t") (N 3)))

fvAexp :: Aexp -> [Var]
fvAexp (N n)        = []
fvAexp (V v)        = v : []
fvAexp (Add a b)    = nub ((fvAexp a) ++ (fvAexp b))
fvAexp (Mult a b)   = nub ((fvAexp a) ++ (fvAexp b))
fvAexp (Sub a b)    = nub ((fvAexp a) ++ (fvAexp b))

-- | Test your function with HUnit.

testFvAexp :: Test
testFvAexp = test ["Free variables of aExp0" ~: ["x"] ~=? fvAexp aExp0,
                   "Free variables of aExp1" ~: ["x", "y"] ~=? fvAexp aExp1,
                   "Free variables of aExp2" ~: ["x", "y", "z"] ~=? fvAexp aExp2,
                   "Free variables of aExp3" ~: ["x", "y", "z", "t"] ~=? fvAexp aExp3]

-- | Define the function 'fvBexp' that computes the set of free variables
-- | occurring in a Boolean expression.

bExp0 :: Bexp
bExp0 = (Eq aExp0 aExp1)

bExp1 :: Bexp
bExp1 = (Le aExp2 aExp3)

bExp2 :: Bexp
bExp2 = (Neg bExp0)

bExp3 :: Bexp
bExp3 = (And bExp1 (Neg bExp2))

fvBexp :: Bexp -> [Var]
fvBexp TRUE         = []
fvBexp FALSE        = []
fvBexp (Eq a b)     = nub ((fvAexp a) ++ (fvAexp b))
fvBexp (Le a b)     = nub ((fvAexp a) ++ (fvAexp b))
fvBexp (Neg b)      = (fvBexp b)
fvBexp (And a b)    = nub ((fvBexp a) ++ (fvBexp b))

-- | Test your function with HUnit.

testFvBexp :: Test
testFvBexp = test ["Free variables of bExp0" ~: ["x", "y"] ~=? fvBexp bExp0,
                   "Free variables of bExp1" ~: ["x", "y", "z", "t"] ~=? fvBexp bExp1,
                   "Free variables of bExp2" ~: ["x", "y"] ~=? fvBexp bExp2,
                   "Free variables of bExp3" ~: ["x", "y", "z", "t"] ~=? fvBexp bExp3]

-- |----------------------------------------------------------------------
-- | Exercise 3
-- |----------------------------------------------------------------------
-- | Given the algebraic data type 'Subst' for representing substitutions:

data Subst = Var :->: Aexp

-- | define a function 'substAexp' that takes an arithmetic expression
-- | 'a' and a substitution 'y:->:a0' and returns the substitution a [y:->:a0];
-- | i.e., replaces every occurrence of 'y' in 'a' by 'a0'.

substAexp :: Aexp -> Subst -> Aexp
substAexp (N n) _ = (N n)
substAexp (V v) (x :->: a0) | v == x   = a0
                            | otherwise = (V v) 
substAexp (Add a b) sub     = (Add (substAexp a sub) (substAexp b sub))
substAexp (Mult a b) sub    = (Mult (substAexp a sub) (substAexp b sub))
substAexp (Sub a b) sub     = (Sub (substAexp a sub) (substAexp b sub))

-- | Test your function with HUnit.

testSubstAexp :: Test
testSubstAexp = test ["Substitution [y :->: (N 3)] in aExp0" ~: aExp0 ~=? substAexp aExp0 ("y" :->: (N 3)),
                      "Substitution [x :->: (V \"w\")] in aExp1" ~: (Mult (V "w") (V "y")) ~=? substAexp aExp1 ("x" :->: (V "w")),
                      "Substitution [z :->: aExp1] in aExp2" ~: (Add (V "x") (Sub (Mult (V "x") (V "y")) (Mult (V "x") (V "y")))) ~=? substAexp aExp2 ("z" :->: aExp1),
                      "Substitution [w :->: (N 10)] in aExp3" ~: (Sub aExp2 (Add (V "t") (N 3))) ~=? substAexp aExp3 ("w" :->: (N 10))]

-- | Define a function 'substBexp' that implements substitution for
-- | Boolean expressions.

substBexp :: Bexp -> Subst -> Bexp
substBexp TRUE _ = TRUE
substBexp FALSE _ = FALSE
substBexp (Eq a b) sub = (Eq (substAexp a sub) (substAexp b sub))
substBexp (Le a b) sub = (Le (substAexp a sub) (substAexp b sub))
substBexp (Neg b) sub = (Neg (substBexp b sub))
substBexp (And a b) sub = (And (substBexp a sub) (substBexp b sub))

-- | Test your function with HUnit.

testSubstBexp :: Test
testSubstBexp = test ["Substitution [y :->: (N 3)] in bExp0" ~: (Eq (V "x") (Mult (V "x") (N 3))) ~=? substBexp bExp0 ("y" :->: (N 3)),
                      "Substitution [x :->: (V \"w\")] in bExp1" ~: Le (Add (V "w") (Sub (Mult (V "w") (V "y")) (V "z"))) (Sub (Add (V "w") (Sub (Mult (V "w") (V "y")) (V "z"))) (Add (V "t") (N 3))) ~=? substBexp bExp1 ("x" :->: (V "w"))]

-- |----------------------------------------------------------------------
-- | Exercise 4
-- |----------------------------------------------------------------------
-- | Given the algebraic data type 'Update' for state updates:

data Update = Var :=>: Z

-- | define a function 'update' that takes a state 's' and an update 'x :=> v'
-- | and returns the updated state 's [x :=> v]'

update :: State -> Update -> State
update s (x :=>: v) = s'
    where 
        s' y    | y == x = v
                | otherwise = s y

-- | Test your function with HUnit.

-- todo

-- | Define a function 'updates' that takes a state 's' and a list of updates
-- | 'us' and returns the updated states resulting from applying the updates
-- | in 'us' from head to tail. For example:
-- |
-- |    updates s ["x" :=>: 1, "y" :=>: 2, "x" :=>: 3]
-- |
-- | returns a state that binds "x" to 3 (the most recent update for "x").

updates :: State ->  [Update] -> State
updates s [] = s
updates s (x:xs) = updates (update s x) xs

-- |----------------------------------------------------------------------
-- | Exercise 5
-- |----------------------------------------------------------------------
-- | Define a function 'foldAexp' to fold an arithmetic expression

foldAexp :: (b -> b -> b) -> 
            (b -> b -> b) -> 
            (b -> b -> b) -> 
            (Var -> b) -> 
            (Integer -> b) ->
            Aexp -> b 
foldAexp j i h g f (N n) = f n
foldAexp j i h g f (V v) = g v
foldAexp j i h g f (Add a1 a2) = h (foldAexp j i h g f a1) (foldAexp j i h g f a2)
foldAexp j i h g f (Sub a1 a2) = i (foldAexp j i h g f a1) (foldAexp j i h g f a2)
foldAexp j i h g f (Mult a1 a2) = j (foldAexp j i h g f a1) (foldAexp j i h g f a2)

-- | Use 'foldAexp' to define the functions 'aVal'', 'fvAexp'', and 'substAexp''
-- | and test your definitions with HUnit.

aVal' :: Aexp -> State -> Z
aVal' exp s = foldAexp (*) (-) (+) s (\ x -> x) exp


fvAexp' :: Aexp -> [Var]
fvAexp' exp = foldAexp h h h g f exp
    where
        f x = []
        g x = x : []
        h a b = nub (a ++ b)

substAexp' :: Aexp -> Subst -> Aexp
substAexp' exp (x :->: v) = foldAexp j i h g f exp
    where
        f x = (N x)
        g y | y == x = v
            | otherwise = (V y)
        h a b = (Add a b)
        i a b = (Sub a b)
        j a b = (Mult a b)

-- | Define a function 'foldBexp' to fold a Boolean expression and use it
-- | to define the functions 'bVal'', 'fvBexp'', and 'substAexp''. Test
-- | your definitions with HUnit.

foldBexp :: (b -> b -> b) ->
            (b -> b) ->
            (Aexp -> Aexp -> b) ->
            (Aexp -> Aexp -> b) ->
            (Bexp -> b) ->
            (Bexp -> b) ->
            Bexp -> b
foldBexp k j i h g f TRUE = f TRUE
foldBexp k j i h g f FALSE = g FALSE
foldBexp k j i h g f (Eq a b) = h a b
foldBexp k j i h g f (Le a b) = i a b
foldBexp k j i h g f (Neg b) = j (foldBexp k j i h g f b)
foldBexp k j i h g f (And a b) = k (foldBexp k j i h g f a) (foldBexp k j i h g f b)

bVal' :: Bexp -> State -> Bool
bVal' exp s = foldBexp k j i h (\ x -> False) (\ x -> True) exp
    where
        h a b = (aVal' a s) == (aVal' b s)
        i a b = (aVal' a s) <= (aVal' b s)
        j b = (not b)
        k a b = a && b

fvBexp' :: Bexp -> [Var]
fvBexp' exp = foldBexp h (\ x -> x) g g f f exp
    where
        f _ = []
        g a b = nub ((fvAexp' a) ++ (fvAexp' b))
        h a b = nub (a ++ b)

substBexp' :: Bexp -> Subst -> Bexp
substBexp' exp (x :->: v) = foldBexp i h g f id id exp
    where
        f a b = (Eq (substAexp' a (x :->: v)) (substAexp' b (x :->: v)))
        g a b = (Le (substAexp' a (x :->: v)) (substAexp' b (x :->: v)))
        h b = (Neg b)
        i a b = (And a b)

