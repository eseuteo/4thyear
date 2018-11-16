{-|
Module      : SUT.hs
Description : Simple example of unit testing with HUnit.
Copyright   : (c) Pablo López, 2017

The functions 'f' and 'suma' are the Subject Under Test.
The unit tests reside in the SUTTest.hs module.
-}

module SUT (suma, Expr(..), valorDe) where

suma :: Num a => [a] -> a
suma []     = 0
suma (x:xs) = x +  suma xs

infixl 6 :+:, :-:
infixl 7 :*:

data Expr = Valor Integer
          | Expr :+: Expr
          | Expr :-: Expr
          | Expr :*: Expr
          deriving Show

valorDe :: Expr -> Integer
valorDe (Valor x)   = x
valorDe (e1 :+: e2) = valorDe e1 + valorDe e2
valorDe (e1 :-: e2) = valorDe e1 - valorDe e2
valorDe (e1 :*: e2) = valorDe e1 * valorDe e2
