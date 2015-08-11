We can easily write lots of variations of scales using Euterpea and Haskell's powerful infinite lists.

> import Euterpea

Let's take some madeup note pattern, and play it over and over (starting on C, all eigth notes)

> songPattern = cycle [0,2,4,5,2,5,7]
> songInC = map (flip trans (C,4)) songPattern
> songV1 = map (note (1/8)) songInC

If we want to make this rhythimcally more interesting, we can add a pattern for the note lengths rather than having all eigth notes. We can combine two lists using some function by using Haskell's 'zipWith' function. 

> rhythmicPattern = cycle [1/16,1/16,1/8]
> songV2 = zipWith note rhythmicPattern songInC

Interstingly, if the lengths of the intervals and rhythms don't line up, the note pattern will come in and out of phase with the rhythmic pattern.

> runme = play $ line $ take 15 songV2
