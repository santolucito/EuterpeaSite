
<apply template="base">

   <div class='row'>
    <div class='col-md-12'>
      <h1 class='page-header'>
        Install
      </h1>
    </div>
  </div>

  <div class='row'>
    <div class='col-md-5 col-md-offset-1'>
    <h3>Installing</h3>
    <p>Euterpea is a library written in Haskell. You will need the <a href='https://wiki.haskell.org/Haskell'>Haskell Platform</a>. Once installed, you can get the lastest <a href='http://hackage.haskell.org/package/Euterpea-1.0.0'>stable release</a> of Euterpea by running...</p>
    <pre>cabal update
cabal install Euterpea</pre>
    </div>
  
    <div class='col-md-5 col-md-offset-1'>
    <h3>Mac</h3>
    <p>If you are on a Mac you will need a midi synthesizer. <a href='http://vmpk.sourceforge.net/'>VMPK</a> has worked well for Mac. Connect VMPK using the Audio/Midi setup program builtin to the Mac OS. Your setup should look like <a href="imgs/mac.png">this</a>.</p>
    <p>You need to compile (i.e. use GHC instead of GHCi) any code using Euterpea's builtin UI library UISF.</p>
    </div>
  </div>
    

  <div class='row'>
    <div class='col-md-5 col-md-offset-1'>
    <h3>Linux</h3>
    <p>If you are on Linux you will need a midi synthesizer. You may also need a soundfont, for example <a href="http://www.personalcopy.com/home.htm">PersonalCopy</a></p>
    <p>Run these commands to get everything you need.</p>
    <pre>apt-get install libasound2-dev
apt-get install timidity
apt-get install vmpk</pre>
    </div>
    
    <div class='col-md-5 col-md-offset-1'>
    <h3>Windows</h3>
    <p>There are no known bugs specific to Windows.</p>
    </div>
  </div>

</apply>
