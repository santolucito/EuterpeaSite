https://www.youtube.com/watch?v=rZrPCnh2QTE

This program demonstrates the basics of composition in Euterpea

> module Main where
> import Euterpea

> main :: IO ()
> main = do
>   play chorale

Here we construct a meldoy using a few of Euterpea's basic music functions

> melody :: Music Pitch
> melody =
>   timesM 2 (line [c 4 qn, d 4 qn, e 4 qn, c 4 qn]) :+:
>   timesM 2 (line [e 4 qn, f 4 qn, g 4 hn]) :+:
>   timesM 2 (line [g 4 en, a 4 en, g 4 en, f 4 en, e 4 qn, c 4 qn]) :+:
>   timesM 2 (line [c 4 qn, g 3 qn, c 4 hn])

We use assign different instrucments to the melody and play them one after another,
each with a two measure delay

> chorale :: Music Pitch
> chorale =
>   Modify (Instrument Tuba) melody :=:
>   Modify (Instrument Trombone) (delayM bn melody) :=:
>   Modify (Instrument Trumpet) (delayM (2*bn) melody) :=:
>   Modify (Instrument TenorSax) (delayM (3*bn) melody)
