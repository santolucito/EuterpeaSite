We can easily write lots of variations of scales using Euterpea and Haskell's powerful infinite lists.

> import Euterpea

We start with am interval pattern of the major scale. From this we can map over the 'trans' function to take a starting note (the root) and create a scale from that note following the pattern specified. It is easy to build modes off this scale pattern by dropping some notes from the beginning (the D Dorian scale is the same as a C Ionian/Major scale that starts on D).

> majorScale :: [Int]
> majorScale = [0,2,4,5,7,9,11] ++ (map (+12) majorScale)

> cIonian = map (note (1/8) . flip trans (C,4)) majorScale
> dIonian = map (note (1/8) . flip trans (D,4)) majorScale
> dDorian = drop 1 $ map (note (1/4) . flip trans (C,4)) majorScale

To play any of these examples, we can take a finite number of notes, and sequence them together using Euterpea's 'line' function

> runme = play $ line $ take 15 dDorian

If we want to make this rhythimcally more interesting, we can add a pattern for the note length. We combine two lists by using Haskell's 'zipWith' function.

> rhythmicPattern :: [Dur]
> rhythmicPattern = cycle [1/16,1/16,1/8]
> cIonian' = zipWith note rhythmicPattern (map (flip trans (C,4)) majorScale)

We can take patterns of intervals and combine them with rhythms. If the lengths of the rhythm and intervals don't line up, the pattern will repeat less often (Least Common Multiple often).

> scalePattern = cycle [0,2,4,5,2,5,7]
> mySong = zipWith note rhythmicPattern (map (flip trans (C,4)) scalePattern)
> mySong' = take 14 mySong ++ (map (transpose 7) mySong)

> --LCM is 21 in this example
> leastCommonMultiple =
>  (length rhythmicPattern) * (length scalePattern)
