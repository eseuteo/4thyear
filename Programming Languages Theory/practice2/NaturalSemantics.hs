{-|

Programming Languages
Fall 2018

Implementation in Haskell of the Natural Semantics described in Chapter 2 of
Nielson & Nielson, Semantics with Applications

Author: Ricardo Holthausen
        Salvador Carrillo Fuentes

-}

module NaturalSemantics where

import           While
import           Exercises01      (Update (..), fvAexp, fvBexp, update)

-- representation of configurations for While

data Config = Inter Stm State  -- <S, s>
            | Final State      -- s

-- representation of the transition relation <S, s> -> s'

nsStm :: Config -> Config

-- x := a

nsStm (Inter (Ass x a) s)      = Final s'
  where
    s' = update s (x :=>: (aVal a s))

-- skip
nsStm (Inter Skip s)           = Final s

-- s1; s2

nsStm (Inter (Comp ss1 ss2) s) = s2
  where
    s2 = Final (sNs ss2 ((sNs ss1 s)))

-- if b then s1 else s2

-- B[b]s = tt
nsStm (Inter (If b ss1 ss2) s) | (bVal b s) = Final (sNs ss1 s)

-- B[b]s = ff
nsStm (Inter (If b ss1 ss2) s) | not (bVal b s) = Final (sNs ss2 s)

-- while b do s

-- B[b]s = ff
nsStm (Inter (While b ss) s) | not (bVal b s) = Final s

-- B[b]s = tt
nsStm (Inter (While b ss) s) | (bVal b s) = s'' 
  where
    s'' = nsStm (Inter (While b ss) (sNs ss s))

-- repeat S until b

-- B[b]s = ff
nsStm (Inter (Repeat ss b) s) | not (bVal b s') = s''
    where
      s' = (sNs ss s)
      s'' = nsStm (Inter (Repeat ss b) s')

-- B[b]s = tt
nsStm (Inter (Repeat ss b) s) | (bVal b s') = Final s'
    where
      s' = (sNs ss s)

-- for x := a1 to a2 do S

-- B[Le x a2]s1 = tt
nsStm (Inter (For v a1 a2 ss) s0) | (bVal (Le (V v) a2) s1) = Final s3
    where
      s1 = sNs (Ass v a1) s0
      s2 = sNs ss s1
      s3 = sNs (For v a1' a2 ss) s2
        where
          a1' = (Add (V v) (N 1))

-- B[Le x a2]s1 = ff
nsStm (Inter (For v a1 a2 ss) s0) | not (bVal (Le (V v) a2) s1) = Final s1
    where
      s1 = sNs (Ass v a1) s0
      

-- semantic function for natural semantics
sNs :: Stm -> State -> State
sNs ss s = s'
  where Final s' = nsStm (Inter ss s)

-- Example C.1
sFac :: State
sFac = sNs factorial sInit
-- End Example C.1
