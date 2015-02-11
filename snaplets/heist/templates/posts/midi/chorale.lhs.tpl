<apply template='base'><p>
<iframe width="420" height="315" src="//www.youtube.com/watch?v=P4j3nCcMJfM" frameborder="0" allowfullscreen></iframe></p>
<p></p>
<p>This program demonstrates the basics of composition in Euterpea</p>
<p></p>
<pre> module Main where</pre>
<pre> import Euterpea</pre>
<p></p>
<pre> main :: IO ()</pre>
<pre> main = do</pre>
<pre>  play chorale</pre>
<p></p>
<p>Here we construct a meldoy using a few of Euterpea's basic music functions</p>
<p></p>
<pre> melody :: Music Pitch</pre>
<pre> melody =</pre>
<pre>   timesM 2 (line [c 4 qn, d 4 qn, e 4 qn, c 4 qn]) :+:</pre>
<pre>   timesM 2 (line [e 4 qn, f 4 qn, g 4 hn]) :+:</pre>
<pre>   timesM 2 (line [g 4 en, a 4 en, g 4 en, f 4 en, e 4 qn, c 4 qn]) :+:</pre>
<pre>   timesM 2 (line [c 4 qn, g 3 qn, c 4 hn])</pre>
<p></p>
<p>We use assign different instrucments to the melody and play them one after another,</p>
<p>each with a two measure delay</p>
<p></p>
<pre> chorale :: Music Pitch</pre>
<pre> chorale =</pre>
<pre>   Modify (Instrument Tuba) melody :=:</pre>
<pre>   Modify (Instrument Trombone) (delayM bn melody) :=:</pre>
<pre>   Modify (Instrument Trumpet) (delayM (2*bn) melody) :=:</pre>
<pre>   Modify (Instrument TenorSax) (delayM (3*bn) melody)</pre>
</apply>
