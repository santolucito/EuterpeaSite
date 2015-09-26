This program demonstrates the basics of composition in Euterpea by building a composition of Frère Jacques.

> module Main where
> import Euterpea

> main :: IO ()
> main = do
>   play round

Here we construct a meldoy using a few of Euterpea's basic music functions. We will make a list of phrases using the 'line' function, which takes a list of Music values and plays them seqentially (using the :+: operator). We can play each of those phrases twice by using the 'timesM' function. With out final list of repeated phrases, we again sequence them together using 'line'.

> melody:: Music Pitch
> melody =
>   let
>     raw = [[c 4 qn, d 4 qn, e 4 qn, c 4 qn],
>            [e 4 qn, f 4 qn, g 4 hn],
>            [g 4 en, a 4 en, g 4 en, f 4 en, e 4 qn, c 4 qn],
>            [c 4 qn, g 3 qn, c 4 hn]]
>     phrases = map (timesM 2 . line) raw
>   in
>     line psTwice


We use assign different instruments to the melody and play them one after another, each with a two measure delay.

> round :: Music Pitch
> round =
>   Modify (Instrument Tuba) melody :=:
>   Modify (Instrument Trombone) (delayM bn melody) :=:
>   Modify (Instrument Trumpet) (delayM (2*bn) melody) :=:
>   Modify (Instrument TenorSax) (delayM (3*bn) melody)
