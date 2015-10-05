Start here! We will quickly go over the most basic functions in Euterpea/Haskell.
Every file should start with something like this.

> module Basics where
> import Euterpea

To make a note in Euterpea we have a special syntax. This note is abstract, it could be midi or we could use it to guide a waveform. This is a concert c quarter note in the fourth octave.
we can play that note, or write it to a file (we are in midi land for now)

> myNote = (c 4 qn)
> myPlay = play myNote
> myWrite = writeMidi "test.mid" myNote

Another way to accomplish tasks like these is to open up our code in GHCi. GHCi is the interactive haskell terminal, and is more powerful than you could ever imagine. Once you are in GHCi (there are plenty of tutorials other places). We can directly type 'play myNote' or 'writeMidi "test.mid" myNote' to excecute the commands. This is like the little brother to live coding.

You will also need a bit about lists. Haskell's lists are well known for being very easy to work with. Conviently, Euterpea has access to any and every function in Haskell. Try and guess what these functions do to the list. You can either play them in ghci to find out, or check out <a href="https://www.haskell.org/hoogle/">Hoogle</a> for clues.

> l1 = [c 4 qn, d 4 qn, e 4 qn]
> l2 = replicate 4 l1
> l3 = reverse l1
> l4 = cycle l1
