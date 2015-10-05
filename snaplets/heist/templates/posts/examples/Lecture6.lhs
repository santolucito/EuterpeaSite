CPSC 431 Examples for lecture #6
Last modified: 28-Jan-2015
Donya Quick

> module Lecture6 where
> import Euterpea
> import System.Random -- for algorithmic composition example
> --The following two imports are to support timing-strict playback
> import Euterpea.ExperimentalPlay 
> import Control.DeepSeq

=============================

A small algorithmic composition

This example will illustrate a lot of the notations discussed
in the last two lectures.

To kick it off, we'll use something not yet covered: random numbers.
The randInts function below will make an infintie series of random 
Ints from a seed. Don't worry about understanding how the this process
works for now; it will be covered later in the course.

> randInts :: Int -> [Int]
> randInts seed = recInts (mkStdGen seed) where
>     recInts g = let (i,g') = next g in i : recInts g'

This numbers from randInts will be over the entire range of the 
integers, so we will need to take the modulo a base to keep them 
in a more usable range. The function below creates a random 
series of integers within a user-specified range.

> randIntsRange :: (Int, Int) -> Int -> [Int]
> randIntsRange (lower, upper) = 
>     map (\i -> (i `mod` (upper-lower)) + lower) . randInts 

We can use this function to generate random pitches and volumes.
The function below will create a random "melody" for a specified
duration, d, using a specified random number seed, s. It uses
the removeZeros function to ensure that zero duration notes don't
cause any playback problems. 

> melGen :: Dur -> Int -> Music (Pitch, Volume)
> melGen d s = removeZeros $ -- this applies to the entire let-in
>     let pitches = map pitch $ randIntsRange (30,80) s
>         vols = randIntsRange (40,100) (s+1)
>     in  takeM d $ line $ map (note sn) $ zip pitches vols

Finally we use this function to create three lines in parallel,
each affected by some Control options.

> somethingWeird = 
>     let part1 = instrument Xylophone $ dim $ rit $ melGen 6 345
>         part2 = instrument Marimba $ melGen 4 234
>         part3 = instrument TubularBells $ cre $ acc $ melGen 8 789
>     in  chord [part1, part2, part3] where
>     rit = phrase [Tmp $ Ritardando 0.5]
>     acc = phrase [Tmp $ Accelerando 0.5]
>     dim = phrase [Dyn $ Diminuendo 0.5]
>     cre = phrase [Dyn $ Crescendo 0.5]

==========================

The following is a customized play function to use some timing 
improvements over the default "play" funtion in Euterpea for 
computation-heavy Music values. 

> playS :: (Performable a, NFData a) => Music a -> IO ()
> playS = playC defParams{strict=True}

In general this sort of special playback function isn't needed, 
but it can be useful for checking correctness of implementations 
and determining whether timing anomalies are playback-related or
are due to the Music value itself.
