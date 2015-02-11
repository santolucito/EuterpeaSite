<apply template='post'><p>
<iframe width="420" height="315" src="https://www.youtube.com/embed/rZrPCnh2QTE" frameborder="0" allowfullscreen></iframe>This program demonstrates the basics of composition in Euterpea</p>
<pre> module Main where
 import Euterpea</pre>
<p></p>
<pre> main :: IO ()
 main = do
   play chorale</pre>
<p>Here we construct a meldoy using a few of Euterpea's basic music functions</p>
<pre> melody :: Music Pitch
 melody =
   timesM 2 (line [c 4 qn, d 4 qn, e 4 qn, c 4 qn]) :+:
   timesM 2 (line [e 4 qn, f 4 qn, g 4 hn]) :+:
   timesM 2 (line [g 4 en, a 4 en, g 4 en, f 4 en, e 4 qn, c 4 qn]) :+:
   timesM 2 (line [c 4 qn, g 3 qn, c 4 hn])</pre>
<p>We use assign different instrucments to the melody and play them one after another,each with a two measure delay</p>
<pre> chorale :: Music Pitch
 chorale =
   Modify (Instrument Tuba) melody :=:
   Modify (Instrument Trombone) (delayM bn melody) :=:
   Modify (Instrument Trumpet) (delayM (2*bn) melody) :=:
   Modify (Instrument TenorSax) (delayM (3*bn) melody)</pre>
</apply>