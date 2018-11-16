{-|

Programming Languages
Fall 2018

Implementation in Haskell of the concepts covered in Chapter 1 of
Nielson & Nielson, Semantics with Applications

Author: Ricardo Holthausen

-}

module Exercises01 where

import           Test.HUnit hiding (State) -- Paquete para unit testing || quickCheck no vale --> :
import           While

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
-- runTestTT testBinVal

testBinVal :: Test
testBinVal = test ["value of zero"  ~: 0 ~=? binVal zero,
                   "value of one"   ~: 1 ~=? binVal one,
                   "value of three" ~: 3 ~=? binVal three,
                   "value of six"   ~: 6 ~=? binVal six]

-- | Define a function 'foldBin' to fold a value of type 'Bin'

-- foldBin :: (Bit -> b -> b) -> b -> Bin -> b
-- foldBin f base (MSB x) = (f x base)
-- foldBin f base (B xs x) = (f x (foldBin f base xs))

-- foldTree :: (a -> b -> b -> b) -> (a -> b) -> b -> Tree a -> b
foldBin :: (Bit -> b) -> (b -> b -> b) -> Bin -> b
foldBin f g (MSB x) = f x
foldBin f g (B xs x) = g (foldBin f g xs) (f x)

-- foldBin :: (Bit -> b) -> (b -> b -> b) -> Bin -> b
-- foldBin uni acu (MSB b) = (uni b)
-- foldBin uni acu (B bin bit) = acu (uni bit) (foldBin uni acu bin)


-- foldBin :: (Bin -> b -> b) -> b -> b -> Bin -> b 
-- foldBin f b0 b1 (MSB O) = b0
-- foldBin f b0 b1 (MSB I) = b1
-- foldBin f b0 b1 (B bin bit) = f bin (foldBin f b0 b1 bin)  


-- | and use 'foldBin' to define a function 'binVal''  equivalent to 'binVal'.

-- binVal' :: Bin -> Z
-- binVal' bin = foldBin id 0 bin
--     where
--         id O x = 2 * x
--         id I x = 2 * x + 1
binVal' :: Bin -> Z
binVal' bin = foldBin id sum bin
    where
        id O = 0
        id I = 1
        sum a b = a + 2 * b

-- | Test your function with HUnit.

testBinVal' :: Test
testBinVal' = test  ["value of zero"  ~: 0 ~=? binVal zero,
                    "value of one"   ~: 1 ~=? binVal one,
                    "value of three" ~: 3 ~=? binVal three,
                    "value of six"   ~: 6 ~=? binVal six]

-- | Define a function 'hammingWeight' that returns the number of ones occurring
-- | in a binary numeral.

hammingWeight :: Bin -> Z
hammingWeight = undefined


-- | and use 'foldBin' to define a function 'hammingWeight''  equivalent to 'hammingWeight'.

hammingWeight' :: Bin -> Z
hammingWeight' bin = foldBin id sum bin
    where
        id O = 0
        id I = 1
        sum a b = a + b
-- hammingWeight' :: Bin -> Integer
-- hammingWeight' bin = foldBin one 0 bin
--     where
--         one O x = x
--         one I x = x + 1

-- | Test your functions with HUnit.

testHammingWeight :: Test
testHammingWeight =     test  [ "value of zero"  ~: 0 ~=? hammingWeight zero,
                                "value of one"   ~: 1 ~=? hammingWeight one,
                                "value of three" ~: 2 ~=? hammingWeight three,
                                "value of six"   ~: 2 ~=? hammingWeight six]

-- testHammingWeight' :: Test
-- testHammingWeight' =    test  [ "value of zero"  ~: 0 ~=? hammingWeight' zero,
--                                 "value of one"   ~: 1 ~=? hammingWeight' one,
--                                 "value of three" ~: 2 ~=? hammingWeight' three,
--                                 "value of six"   ~: 2 ~=? hammingWeight' six]

-- | Define a function 'complement' that returns the complement of a binary numeral

complement :: Bin -> Bin
complement (MSB O) = (MSB I)
complement (MSB I) = (MSB O)
complement (B bin O) = (B (complement bin) I)
complement (B bin I) = (B (complement bin) O)

-- | and use 'foldBin' to define a function 'complement''  equivalent to 'complement'.
-- asd (x:xs) = foldr f x xs

complement' :: Bin -> Bin
complement' bin = foldBin comp g bin
    where
        comp O = (MSB I)
        comp I = (MSB O)
        g (MSB x) xs = (B xs x)


-- complement' :: Bin -> Bin
-- complement' bin = foldBin comp bin bin
--     where
--         comp O x = (B x I)
--         comp I x = (B x O)


-- | Test your functions with HUnit.

-- todo

-- | Define a function 'normalize' that given a binary numeral trims leading zeroes.

normalize :: Bin -> Bin
normalize (MSB x) = (MSB x)
normalize (B xs x)  | x == O    = normalize xs
                    | otherwise = (B xs x)

-- | and use 'foldBin' to define a function 'normalize''  equivalent to 'normalize'.

normalize' :: Bin -> Bin
normalize' bin = foldr norm g bin
    where

-- | Test your functions with HUnit.

-- todo

-- |----------------------------------------------------------------------
-- | Exercise 2
-- |----------------------------------------------------------------------
-- | Define the function 'fvAexp' that computes the set of free variables
-- | occurring in an arithmetic expression. Ensure that each free variable
-- | occurs once in the resulting list.

fvAexp :: Aexp -> [Var]
fvAexp = undefined

-- | Test your function with HUnit.

-- todo

-- | Define the function 'fvBexp' that computes the set of free variables
-- | occurring in a Boolean expression.

fvBexp :: Bexp -> [Var]
fvBexp = undefined

-- | Test your function with HUnit.

-- todo

-- |----------------------------------------------------------------------
-- | Exercise 3
-- |----------------------------------------------------------------------
-- | Given the algebraic data type 'Subst' for representing substitutions:

data Subst = Var :->: Aexp

-- | define a function 'substAexp' that takes an arithmetic expression
-- | 'a' and a substitution 'y:->:a0' and returns the substitution a [y:->:a0];
-- | i.e., replaces every occurrence of 'y' in 'a' by 'a0'.

substAexp :: Aexp -> Subst -> Aexp
substAexp = undefined

-- | Test your function with HUnit.

-- todo

-- | Define a function 'substBexp' that implements substitution for
-- | Boolean expressions.

substBexp :: Bexp -> Subst -> Bexp
substBexp = undefined

-- | Test your function with HUnit.

-- todo

-- |----------------------------------------------------------------------
-- | Exercise 4
-- |----------------------------------------------------------------------
-- | Given the algebraic data type 'Update' for state updates:

data Update = Var :=>: Z

-- | define a function 'update' that takes a state 's' and an update 'x :=> v'
-- | and returns the updated state 's [x :=> v]'

update :: State -> Update -> State
update = undefined

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
updates = undefined

-- |----------------------------------------------------------------------
-- | Exercise 5
-- |----------------------------------------------------------------------
-- | Define a function 'foldAexp' to fold an arithmetic expression

foldAexp :: a
foldAexp = undefined

-- | Use 'foldAexp' to define the functions 'aVal'', 'fvAexp'', and 'substAexp''
-- | and test your definitions with HUnit.

aVal' :: Aexp -> State -> Z
aVal' = undefined

fvAexp' :: Aexp -> [Var]
fvAexp' = undefined

substAexp' :: Aexp -> Subst -> Aexp
substAexp' = undefined

-- | Define a function 'foldBexp' to fold a Boolean expression and use it
-- | to define the functions 'bVal'', 'fvBexp'', and 'substAexp''. Test
-- | your definitions with HUnit.

foldBexp :: a
foldBexp = undefined

bVal' :: Bexp -> State -> Bool
bVal' = undefined

fvBexp' :: Bexp -> [Var]
fvBexp' = undefined

substBexp' :: Bexp -> Subst -> Bexp
substBexp' = undefined
