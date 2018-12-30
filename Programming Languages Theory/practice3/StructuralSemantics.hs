{-|

Programming Languages
Fall 2018

Implementation in Haskell of the Structural Operational Semantics
described in Chapter 2 of Nielson & Nielson, Semantics with Applications

Authors:  Ricardo Holthausen
          Salvador Carrillo Fuentes

-}

module StructuralSemantics where

import           ExWhile

-- representation of configurations for While

data Config = Inter Stm State  -- <S, s>
            | Final State      -- s

isFinal :: Config -> Bool
isFinal (Inter ss s) = False
isFinal (Final s)    = True

isAbort :: Config -> Bool
isAbort (Inter Abort s) = True
isAbort (Inter (Comp Abort _) s) = True
isAbort _            = False

-- representation of the transition relation <S, s> -> s'

sosStm :: Config -> Config

-- x := a

sosStm (Inter (Ass x a) s) = Final (update s x (aVal a s))
  where
    update s x v y = if x == y then v else s y

-- skip

sosStm (Inter Skip s) = Final s

-- s1; s2

sosStm (Inter (Comp ss1 ss2) s) | isFinal next = Inter ss2 s'
                                | otherwise = Inter (Comp ss1' ss2) s''
    where
      next = sosStm (Inter ss1 s)
      Final s' = sosStm (Inter ss1 s)
      Inter ss1' s'' = sosStm (Inter ss1 s)

-- if b then s1 else s2

sosStm (Inter (If b ss1 ss2) s) 
  | bVal b s  = Inter ss1 s
  | otherwise = Inter ss2 s

-- while b do s

sosStm (Inter while@(While b ss) s) = Inter (If b ss1 ss2) s
    where
      ss1 = Comp ss while
      ss2 = Skip

-- repeat s b

sosStm (Inter repeat@(Repeat ss b) s) = Inter (Comp ss ss1) s
    where
      ss1 = If b Skip repeat

-- abort

sosStm (Inter Abort s) = Inter Abort s


