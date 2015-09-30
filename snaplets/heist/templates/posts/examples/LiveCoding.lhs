we are going to do some live coding in Euterpea!

> module LiveCoding where

For now, we need a lot of imports and extra funcions. This should all go away as the Euterpea team develops the library.

> import Euterpea
> import Euterpea.IO.MIDI.MidiIO
> import Control.Concurrent
> import Euterpea.IO.MUI.MidiWidgets
> import Control.Monad
> import Codec.Midi (Time)
>
> type MidiEvent = (Codec.Midi.Time, MidiMessage)
> toMidi' :: Music Pitch -> [MidiEvent]
> toMidi' m = musicToMsgs False [AcousticGrandPiano] (toMusic1 m)

We will need to setup the system and get the device id we want to play on. The setup process will start a listener on the midi device on a seperate core. If you dont have a multicore system, this will probably not work very well.

getD is just going to grab the first midi device it sees, you might want to adjust this depending on your system.
 
> setup :: IO ()
> setup = do
>   allDevs <- getAllDevices
>   let devID = fst $ head $ snd allDevs 
>   forkIO $ forever $ outputMidi devID
>   return ()
> 
> getD :: IO (OutputDeviceID)
> getD = do
>   allDevs <- getAllDevices
>   let devID = fst $ head $ snd allDevs
>   return devID

The function we will use to do the actual live coding.

> playLive id m = do
>   mapM_ (deliverMidiEvent id) (toMidi' m)

Let give ourselves some music to play with

> toNote pc = pc 4 qn
> mel = line $ map toNote $ concat $ replicate 10 [c, d, e, c]
> mel' = line $ map toNote $ concat $ replicate 10 [e, f, g, g]

Since this is live coding, we will be using ghci. type in the following to see how it works.

ghci> let d = getD

ghci> playLive d mel

ghci> playLive d mel'

Notice that there is no syncronization, so everything sounds a bit jittery. We are working on it...


