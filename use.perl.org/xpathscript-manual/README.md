---
title: Enter the XPathScript manual
url: xpathscript-manual
format: markdown
created: 2006-08-15
last_updated:
original: use.perl.org - http://use.perl.org/~Yanick/journal/30648
tags:
    - XML::XPathScript
    - manual
    - XML::LibXML
    - Pod::Parser
    - YAML::Loader
---

<p>As XPathScript is growing to be a pretty beefy module, I wanted to collect all its manpages into a manual. So I did the obvious: I wrote a script that... </p>

<p>...uses Pod::Parser to extract the pod from the distribution...
</p><p>(and YAML::Loader to get a few infos from META.yaml),</p><p>...passed it through
Pod::DocBook to get a DocBook representation of the document,...</p><p>...massaged it with XML::LibXML...</p><p>...used XPathScript to convert the result into LaTeX...</p><p>...which finally can be compiled into PDF (*pant* *pant* *pant*).</p><p> The <a href="http://babyl.dyndns.org/misc/xps.pdf" rel="nofollow">result</a>  doesn't look too bad, I am tempted to say.</p>
	
    
