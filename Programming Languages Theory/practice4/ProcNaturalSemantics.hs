----------------------------------------------------------------------
--
-- ProcNaturalSemantics.hs
-- Programming Languages
-- Fall 2018
--
-- Natural Semantics for Proc
-- [Nielson and Nielson, semantics with applications]
--
-- Authors:  Salvador Carrillo Fuentes
--           Ricardo Holthausen Bermejo
----------------------------------------------------------------------

module ProcNaturalSemantics where

import           Proc

----------------------------------------------------------------------
-- Variable Declarations
----------------------------------------------------------------------

-- locations

type Loc = Integer

new :: Loc -> Loc
new l = l + 1

-- variable environment

type EnvVar = Var -> Loc

-- store

-- 'sto [next]' refers to the first available cell in the store 'sto'
next :: Loc
next = 0

type Store = Loc -> Z

-- | Exercise 1.1

-- update a variable environment with a new binding envV [x -> l]
updateV :: EnvVar -> Var -> Loc -> EnvVar
updateV envV x l = newEnvV
    where
        newEnvV y   | y == x = l
                    | otherwise = envV y
-- Con lambdas:
--      \ y -> if x == y then l else envV y
        

-- update a store with a new binding sto [l -> v]
updateS :: Store -> Loc -> Z -> Store
updateS sto l v
        newSto y    | y == l = v
                    | otherwise = sto l
-- Con lambdas:
--      \ d -> if d == l then v else sto d

-- variable declaration configurations

data ConfigD = InterD DecVar EnvVar Store  -- <Dv, envV, store>
             | FinalD EnvVar Store         -- <envV, store>

nsDecV :: ConfigD -> ConfigD

-- | Exercise 1.2

-- var x := a
nsDecV (InterD (Dec x a decs) envV store) = nsDecV (Inter decs envV' store')
    where
        envV' = updateV envV x next
        store' = updateS store next a

        -- Corrección
        -- nsDecV (InterD decs (updateV envV x l) (updateS (updateS store l v) next (new l)))
        --      where
        --          l = store next
        --          v = aVal a (store . env)
                                        

-- epsilon
nsDecV (InterD EndDec envV store)         = FinalD envV store

----------------------------------------------------------------------
-- Procedure Declarations
----------------------------------------------------------------------

-- procedure environment

--                    p    s    snapshots    previous
--                    |    |     /    \         |
data EnvProc = EnvP Pname Stm EnvVar EnvProc EnvProc
             | EmptyEnvProc

-- | Exercise 2.1

-- update the procedure environment
updP :: DecProc -> EnvVar -> EnvProc -> EnvProc
updP (Proc p s procs) envV envP = undefined
updP EndProc envV envP          = undefined

-- | Exercise 2.2

-- lookup procedure p
envProc :: EnvProc -> Pname -> (Stm, EnvVar, EnvProc)
envProc (EnvP q s envV envP envs) p = undefined
envProc EmptyEnvProc p              = undefined

-- representation of configurations for Proc

data Config = Inter Stm Store  -- <S, sto>
            | Final Store      -- sto

-- representation of the transition relation <S, sto> -> stos'

nsStm :: EnvVar -> EnvProc -> Config -> Config

-- | Exercise 3.1

-- x := a

nsStm envV envP (Inter (Ass x a) sto)            = undefined


-- skip

nsStm envV envP (Inter Skip sto)                 = undefined


-- s1; s2

nsStm envV envP (Inter (Comp ss1 ss2) sto)       = undefined

-- if b then s1 else s2

nsStm envV envP (Inter (If b s1 s2) sto)         = undefined

-- while b do s

nsStm envV envP (Inter (While b s) sto)          = undefined

-- block vars procs s

nsStm envV envP (Inter (Block vars procs s) sto) = undefined

-- non-recursive procedure call
{-
nsStm envV envP (Inter (Call p) sto) = undefined


-}

-- recursive procedure call
nsStm envV envP (Inter (Call p) sto)             = undefined

-- | Exercise 3.2

sNs :: Stm -> Store -> Store
sNs s sto = undefined
