Welcome to the Euterpea tutorial on dubstep production

> import Euterpea

typically a tempo of 140 bpm is selected. 
ourTempo = 

First we being with a typicaly kick and snare pattern, like so

> kick = 
>  let 
>    r = rest (3/16)
>    h = perc ElectricSnare (1/16) :+: r
>    b = perc BassDrum1 (1/16) :+: r
>  in instrument Percussion $ 
>    timesM 2 (b :+: h)

Next its time to add some hihats and cymbals to fill those spaces

> hihat = 
>  let
>    r = rest (1/16)
>    h = perc ClosedHiHat (1/16)
>  in instrument Percussion $ 
>    line [h,h,r,h,
>          h,r,h,h,
>          h,r,h,r,
>          h,r,r,h]

> main = play $ 
>   timesM 2 kick :+:
>   (timesM 2 kick) :=: (timesM 2 hihat)
>   
