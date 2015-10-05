Daniel Jackowitz (dj258)
CS432 - Final Project

> {-# LANGUAGE Arrows #-}
> module BabaORiley where
> import Euterpea
> import Control.Arrow ((>>>),(<<<),arr)

The pulsating introduction to the song "Baba O'Riley" by The Who is one of the
most iconic 45 seconds in music. It is also one of the most mysterious. First
appearing on the album "Who's Next" in 1971, the recording was right on the
bleeding edge of synthesizers in popular music and surfaced shortly after the
song's composer, Pete Townshend, had taken delivery of an ARP 2600 synthesizer,
the latest and greatest at the time. All evidence pointed to the ARP as the
source of the iconic sound but no else was able to reproduce it accurately even
using the supposed same equipment. It was only years later that the truth
surfaced - the most famous synthesizer sound wasn't even a synthesizer at all!
It was in fact a Lowrey TBO-1 home organ, a bottom-of-the-line household model,
but with one special setting that left it's mark on a generation of music.

We will generate that sound in the proceeding code. You can listen to the final product here.

<audio controls>
  <source src="/baba.mp3" type="audio/wav">
Your browser does not support the audio element.
</audio>

The organ sound itself is typical of a cheap organ from the time period. It is
most closely approximated by two thin pulse waves (15% duty cycle) harmonized 
an octave apart. This gives some depth to the sound but, in general, is quite 
lacking on its own, as organBaseSound demonstrates.

> pulseTable :: Table
> pulseTable = tableLinearN 4096 1 [(0.15, 1), (0, -1), (0.85, -1)]

> pulseOsc :: AudSF Double Double
> pulseOsc = osc squareTable 0

> octaverOsc :: AudSF Double Double
> octaverOsc = proc f -> do
>   note   <- pulseOsc -< f
>   octave <- pulseOsc -< 2*f
>   outA -< (note + octave) / 2

> organBaseSound = outFile "OrganBaseSound.wav" 3 (octaverOsc <<< constA 220)

In addition to the dozen or so settings (poorly) approximating many traditional
instruments, several Lowrey models (most notably the TBO-1 used on the track
in question) also had an "effects bank" for further sound manipulation. Many
of the included effects were quite typical, such as tremolo and vibrato. Not
so typical was the "Miramba Repeat" setting. This unique effect can be best
described as a pseudo-delay, but with an added twist - depending on what
musical note was played, the notes would propagate either strictly on the
beat or strictly off the beat. More specifically, notes F-G and B-C# would
fall ON the beat, while G#-A# and D-E would fall OFF the beat. The effect is
most clearly demonstrated by simultaneously playing one note from each group
and listening as the pitches "bounce" with the beat, as in mirambaRepeatDemo
at the bottom of this file.

I have described the Miramba Repeat as a "psuedo-delay" because while the
effect clearly sounds like a member of the delay family, the implementation
itself makes no use of any sort of delay. It is actually the result of two
low frequency square wave oscillators controlling the note volume as a very
sharp tremolo. The phases of the two oscillators are offset by exactly half
a cycle, resulting in the "ON" states being mutually exclusive. When a note
on the keyboard is played with the effect enabled, a simple circuit routes
the signal through the appropriate oscillator depending on its musical pitch.
This same logic is seen below in lfo. Here squareOsc' sounds ON the beat
while squareOsc'' sounds OFF the beat. The note parsing logic is somewhat
simplified for clarity as "Baba O'Riley" is strictly in the key of F.

> squareTable :: Table
> squareTable = tableLinearN 4096 1 [(0.5, 1), (0, -1), (0.5, -1)]

> squareOsc', squareOsc'' :: AudSF Double Double
> squareOsc' = osc squareTable 0
> squareOsc'' = osc squareTable 0.5

> lfo :: Pitch -> AudSF Double Double
> lfo (C, _)  = squareOsc'
> lfo (D, _)  = squareOsc''
> lfo (E, _)  = squareOsc''
> lfo (F, _)  = squareOsc'
> lfo (G, _)  = squareOsc'
> lfo (A, _)  = squareOsc''
> lfo (Bf, _) = squareOsc''
> lfo (_, _)  = squareOsc'

With the virtual instrument all sorted out, it's time to address the song
itself. Reverse engineering the score was a bit more difficult than usual as
the Miramba Repeat produces many "phantom" notes that must be parsed out.
Fortunately this was a task I had attempted before and after an hour or so
with Audacity I think I have separated pretty accurately what Pete Townshend
(the performer) actually played from what the effect had added. Since the
track was played live by a human performer there are some minor variations
that I simply cannot account for programmatically, but the score outlined
below is certainly "close enough for Rock 'n Roll".

The most prominent figure in the organ part is also the simplest - the root,
fifth, octave arpeggio that loops under the entirety of the song. This is
played on the top keyboard of the organ using the left hand and can be seen
as rootFifth below. Since F and C both fall on the beat, this line sounds as
a steady, pulsating beat. As the introduction progresses, the right hand adds 
a series of flourishes, all variations on a common theme and all making
extensive use of the interplay between the two oscillators. It is these
flourishes that give the track such a distinctive sound and make it so
difficult to reproduce on any instrument without an accurate Miramba Repeat.

> rootFifth :: Music Pitch
> rootFifth = line [f 4 en, c 5 en, f 5 en, c 5 en]

> flourish1, flourish2, flourish3 :: Music Pitch
> flourish1 = line [d 5 qn, e 5 sn, denr]
> flourish2 = line [qnr, d 5 en, e 5 en]
> flourish3 = line [dqnr, d 5 en]

> flourish4, flourish5, flourish6 :: Music Pitch
> flourish4 = line [enr, e 5 en, qnr]
> flourish5 = line [enr, d 5 en, e 5 en, enr]
> flourish6 = line [enr, bf 4 en, d 5 en, enr]

Layering the ever-repeating rootFifth figure with a carefully crafted sequence
of flourishes, the following arrangement represents the entirety of the iconic
introduction. The score is actually extraordinarily simple considering how
complex it sounds, illustrating the importance of the Miramba Repeat. 

> arrangement :: Music Pitch
> arrangement = Modify (Tempo 0.975) (
>                (timesM 4   rootFifth) :+: 
>                (timesM 1  (rootFifth :=: flourish1)) :+:
>                (timesM 12 (rootFifth :=: flourish2)) :+:
>                (timesM 8  (rootFifth :=: flourish3)) :+:
>                (timesM 1  (rootFifth :=: flourish4)) :+:
>                (timesM 11 (rootFifth :=: flourish5)) :+:
>                (timesM 4  (rootFifth :=: flourish6))
>               )

With the two LFOs and the octaver already implemented, the Lowrey TBO-1 organ
model itself becomes fairly trivial as it just wires the modules together.

> lowreyOrgan :: Instr (Mono AudRate)
> lowreyOrgan dur ap vol [] =
>   let f = apToHz ap
>       v = fromIntegral vol / 100
>       d = fromRational dur
>   in proc () -> do
>       lfo    <- lfo (pitch ap) -< 8
>       signal <- octaverOsc     -< f
>       outA -< signal * (0.75 + 0.25*lfo) * v/4

For the simplest illustration of the Miramba Repeat effect, this demo plays
two notes simultanously. C sounds ON the beat, while D sounds OFF, creating
a unique "bounce" effect.

> mirambaRepeatDemo = uncurry (outFile "MirambaRepeatDemo.wav") $
>          renderSF (instrument (Custom "Lowrey Organ")
>          (chord [c 5 wn, d 4 wn]))
>          [(Custom "Lowrey Organ", lowreyOrgan)]

The Main Event:
The Euterpea render of the first 45 seconds (the organ intro) of the song
"Baba O'Riley" by The Who.

> babaORiley = uncurry (outFile "BabaORiley.wav") $
>          renderSF (instrument (Custom "Lowrey Organ") arrangement)
>          [(Custom "Lowrey Organ", lowreyOrgan)]

