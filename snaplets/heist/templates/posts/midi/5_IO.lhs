We will need to use arrows

>{-#  LANGUAGE Arrows #-}
> module Main where
> import Data.Maybe
> import Euterpea

We will be making a interactive MUI (musical user interface)

> main = runMUI' ui

using some prebuilt stuff, we can quickly patch togther what we need

> ui   :: UISF () ()
> ui   = proc _ -> do
>    mi  <- selectInput   -< ()
>    mo  <- selectOutput  -< ()
>    m   <- midiIn        -< mi
>    midiOut -< (mo, fmap foo m)

A little function that will make an interval out of a midi note

> interval :: Int -> MidiMessage -> [MidiMessage]
> interval i m = 
>  case m of
>   Std (NoteOn c k v) -> [Std (NoteOn c k v), Std (NoteOn c (k+i) v)]
>   Std (NoteOff c k v) -> [Std (NoteOff c k v), Std (NoteOff c (k+i) v)]
>   _ -> []

then we apply interval function to all the incoming messages. This is automatically lifted to the signal domain by the arrows!

> foo :: [MidiMessage] -> [MidiMessage]
> foo xs =
>  concatMap (interval 3) xs
