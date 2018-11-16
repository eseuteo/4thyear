{-|
Module      : SUTTest.hs
Description : Simple example of unit testing with HUnit.
Copyright   : (c) Pablo López, 2017

The functions 'suma', and 'valorDe' are imported from SUT.hs (Subject Under Test)
-}

module SUTTest where

import           SUT        (Expr (..), suma, valorDe)
import           Test.HUnit

-- | simple examples (see slides)

testSimple :: Test
testSimple = 55 ~=? suma [1..10]

testSimpleConMensaje :: Test
testSimpleConMensaje = "suma [1..10] /= 55" ~: 55 ~=? suma [1..10]

testBooleano :: Test
testBooleano = 1 <= 2 ~? "1 debe ser menor o igual que 2"

listaTests :: Test
listaTests =
  TestList [ "suma [1..10] /= 55" ~: 55 ~=? suma [1..10],
             1 <= 2 ~? "1 debe ser menor o igual que 2"
           ]

agrupaTests :: Test
agrupaTests =
   test ["suma [1..10] /= 55" ~: 55 ~=? suma [1..10],
          1 <= 2 ~? "1 debe ser menor o igual que 2"
        ]

-- | unit testing for 'suma'

testSumaNull :: Test
testSumaNull = "sum null list" ~: 0 ~=? suma []

testSumaSingleton :: Test
testSumaSingleton = "sum singleton list"  ~: 1 ~=? suma [1]

testSumaTwoElements :: Test
testSumaTwoElements = suma [1,2] /= 4 ~? "assertNotEqual is not defined" -- assertBool

testSumaThreeElements :: Test
testSumaThreeElements = "sum list with 3 elements" ~:  6 ~=? suma [1,2,3]

-- | group tests for 'suma'

testsSuma :: Test
testsSuma = test [ testSumaNull,
                   testSumaSingleton,
                   testSumaTwoElements,
                   testSumaThreeElements]

-- | testing an arithmetic expression

-- 3 + 5 * 2 - 1 = (3 + (5*2)) - 1
exp1 :: Expr
exp1 = Valor 3 :+: Valor 5 :*: Valor 2 :-: Valor 1

-- (3+1) * (5+2*6-1) = (3+1) * ((5+(2*6))-1)
exp2 :: Expr
exp2 = (Valor 3 :+: Valor 1) :*: (Valor 5 :+: Valor 2 :*: Valor 6 :-: Valor 1)

testValorDe :: Test
testValorDe = TestList [ "valor de exp1 no es 12" ~: 12 ~=? valorDe exp1,
                         "valor de exp2 no es 64" ~: 64 ~=? valorDe exp2
                       ]

-- | group all tests 'suma', and 'valorDe'

allTests :: Test
allTests = TestList [testSumaNull,
                     testSumaSingleton,
                     testSumaThreeElements,
                     testSumaTwoElements,
                     testsSuma,
                     testValorDe]

-- | run a particular test

runTestSumaSingleton :: IO Counts
runTestSumaSingleton = runTestTT testSumaSingleton

-- | run test for 'valorDe'

runTestValorDe :: IO Counts
runTestValorDe = runTestTT testValorDe

-- | run tests for 'suma'

runTestsSuma :: IO Counts
runTestsSuma = runTestTT testsSuma

-- | run all tests

runAllTests :: IO Counts
runAllTests = runTestTT allTests

-- | use a 'main' function in the testing unit

main :: IO ()
main = do
         testReport <- runTestTT allTests
         print $ show testReport
