We can easily write lots of variations of scales using Euterpea and Haskell's powerful infinite lists.

> import Euterpea

We start with an interval pattern of the major scale. Haskell allows for infinite lists, so we make a list that continues up the major scale forever by using a recursive definition. 

> countExample = [1] ++ (map (+1) countExample) -- [1,2,3,4...]
> majorScale = [0,2,4,5,7,9,11] ++ (map (+12) majorScale)

We will need a function that takes a pitch and an interval to transpose, and gives us back a new pitch.

> trans' origPitch i =
>   pitch ((absPitch origPitch) + i)

From this we can map over the 'trans' function to take a starting note (the root) and create a scale from that note following the pattern specified. It is easy to build modes off this scale pattern by dropping some notes from the beginning (the D Dorian scale is the same as a C Ionian/Major scale that starts on D).

> cIonian = map (note (1/8)) (map (trans' (C,4)) majorScale)
> --a more haskell style version for dIonian, same idea though
> dIonian = map (note (1/8) . trans' (D,4)) majorScale
> dDorian = drop 1 $ map (note (1/4) . trans' (C,4)) majorScale

To play any of these examples, we take a finite number of notes from the infinite list, and sequence them together using Euterpea's 'line' function. 

> runme = play $ line $ take 15 dDorian

