---
title: Perlish theme for Friends, Fans and Foes 
url: friends-fans-and-foes
format: html
created: 2006-08-24
last_updated: 
original: use.perl.org - http://use.perl.org/~Yanick/journal/30746
tags:
    - firefox
    - stylish
---
<p>Today I discovered <a href="http://userstyles.org/stylish/" rel="nofollow">Stylish</a>, a very cool Firefox plugin to create per domain/site/page CSS style. To test it, I decided to give a Perlish flair to the Friend/Fan/Foe icons on use.perl.org:</p>
<pre>@-moz-document domain("use.perl.org") {
img[alt="Friend"] {
   background: url(http://babyl.dyndns.org/misc/camel.png) top left no-repeat !important;
   padding-top:16px !important;<br/>   width:16px !important;<br/>   height:0px !important;<br/>}<br/>img[alt="Friend of Friend"] {<br/>   background: url(http://babyl.dyndns.org/misc/llama.png) top left no-repeat !important;<br/>   padding-top:16px !important;<br/>   width:16px !important;<br/>   height:0px !important;<br/>}<br/>img[alt="Fan"] {<br/>   background: url(http://babyl.dyndns.org/misc/dog.png) top left no-repeat !important;<br/>   padding-top:16px !important;<br/>   width:16px !important;<br/>   height:0px !important;<br/>}<br/> <br/>img[alt="Foe"] {<br/>   background: url(http://babyl.dyndns.org/misc/panther.png) top left no-repeat !important;<br/>   padding-top:16px !important;<br/>   width:16px !important;<br/>   height:0px !important;<br/>}<br/> <br/>img[alt="Neutral"] {<br/>   background: url(http://babyl.dyndns.org/misc/ram.png) top left no-repeat !important;<br/>   padding-top:16px !important;<br/>   width:16px !important;<br/>   height:0px !important;<br/>}<br/>}
</pre>
<p>Here's a <a href="http://babyl.dyndns.org/misc/use_perl_screenshot.png" rel="nofollow"> screenshot</a> of the result.</p>
