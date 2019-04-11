---
title: FOSSLC debate -- Which Open Source license is best?
url: fosslc-debate-which-open-source-license-is-best
original: the Pythian blog - http://www.pythian.com/news/4006/fosslc-debate-which-open-source-license-is-best
created: 2009-09-28
markup: html
tags:
    - Airbus
    - bsd
    - eclipse
    - EPL
    - fosscl
    - FOSSLC
    - gnu
    - gpl
    - IBM
    - license
    - Licensing
    - MySQL
    - Nokia
    - open source
    - Open Source Software
    - Rational
    - Richard Stallman
    - Simian
---

<p>On Monday August 31<sup>st</sup>, Gowlings hosted a <a href="http://fosslc.org/drupal/node/407">debate on open source licenses</a> organized by <a href="http://www.fosslc.org/drupal/">the Free and Open Source Software Learning Centre (FOSSLC)</a>.</p>

<p>The debate was conducted between the proponents of three major Open Source licenses: Mike Milinkovich for the EPL, Matt Asay for the GPL, and David Maxwell for the BSD license.</p>

<p>It was organized into three rounds: first the panelists had ten minutes to sell us their license of choice. Then they were given five minutes to rebut points made by the two other panelists. A final one minute was given to rebut any rebuttal. After those three rounds, the audience—both the live one and that watching the feed—asked their questions.</p>

<p>From what I could estimate, between 50 and 70 people physically attended the event. Andrew reported that between 25 and 50 viewed the live feed. <a href="http://fosslc.org/drupal/node/524">Videos of the event</a> are available on the FOSSLC site.</p>

<h3>The Players</h3><h4>FOSSLC</h4>

<p><a href="//www.fosslc.org">FOSSLC</a> is the <em>Free and Open Source Software Learning Centre</em>, a non-for-profit organization dedicated to the promotion of Open Source software. It is a relatively young organization, having been around for barely two years, but already it has chapters in Canada, Germany, and the United States. It is helmed by Andrew Ross, who works at <a href="http://www.ingres.com">Ingres</a>.</p>

<h4>Gowlings</h4>

<p>The host and one of the sponsors of the event. <a href="http://www.gowlings.com">Gowlings</a> is a large Canadian law firm. Obviously, they have an interest in the wonderfully convoluted world of software licenses.</p>

<h4>The Panelists</h4>

<p>Mike Milinkovich, defending the EPL, is the Executive Director of the <a href="http://eclipse.org">Eclipse Foundation</a>. Which comes to no big surprise considering that the <em>E</em> of EPL is <em>Eclipse</em>.</p>

<p>Matt Asay, representing the GPL, is the VP of Business Development for <a href="http://alfresco.com">Alfresco</a>, a California-based company concerned with content-based management.</p>

<p>David Maxwell, representing the BSD license, is an Open Source strategist at <a href="http://coverity.com">Coverity</a>, a software integrity company.</p>

<h4>The Licenses</h4>

<p>EPL is the <a href="http://en.wikipedia.org/wiki/Eclipse_Public_License">Eclipse Public License</a>, used by Eclipse for its software.</p>

<p>GPL is the <a href="http://en.wikipedia.org/wiki/Gpl">GNU General Public License</a>, originally written by Richard Stallman for the GNU Project.</p>

<p>The <a href="http://en.wikipedia.org/wiki/BSD_licenses">BSD license</a> is the license originally created for the BSD (Berkeley Software Distribution) UNIX operating system.</p>

<p>It should be noted that all three licenses are approved by the <a href="http://opensource.org/">Open Source Initiative</a> and <a href="http://www.fsf.org/">Free Software Foundation</a>.</p>

<h3>Let the Battle Begin</h3>

<p>So, which license is best? The answer is: <em>it depends</em>.</p>

<p>In more detail, it depends on several factors:</p>

<ul><li>Your business model. Are you going to redistribute software? Or<br /> provide technical support?</li><li>Are you aiming for adoption or monetization of your code?</li><li>What kind of community and eco-system are you trying to foster around your software?</li><li>Where your developers stand—developers sometimes have strong feelings for/against certain alternatives.</li><li>Are you opening code that is a complement, or the core of your business?</li> </ul><h4>General Points on Licenses</h4>

<p>To be blunt, we can divide licenses into three types:</p>

<ul><li>Gimme credit (e.g., BSD)</li><li>Gimme changes (e.g., EPL)</li><li>Gimme everything (e.g., GPL)</li> </ul>

<p>There are many more Open Source licences out there than the three presented in the debate, but these represent of the three main types of licenses. For more information, the OSI website keeps a list of all <a href="http://opensource.org/licenses/category">its approved licenses</a>, divided into categories.</p>

<p>A rule of thumb is: if the code is complement to your business, release it under a lax license (as to maximize adoption and promote community involvement). If it’s core to your business, consider something that will protect you more.</p>

<p>Dual-licensing is a compromise between openness and keeping control. MySQL is a good example of a project that successfully used this system (it was advanced in the debate that MySQL was in fact the first to use dual licenses).</p>

<h4>The Eclipse Public License (EPL)</h4>

<p>It appears to be the most company-friendly license of the trio, and has been described in semi-jest as having been written for lawyers.</p>

<p>Its gist is: if you take code licensed under the EPL and generate derivative work, this work has to be donated back under the same license. If, however, you use the EPL’ed code without modification in your application’s stack, you can do whatever you want. This allows for companies to use Open Source code without having to face an “all or nothing” sharing situation.</p>

<p>Some of its users are Eclipse (natch), IBM’s Rational, Nokia (via Simian), and Airbus.</p>

<h4>The GNU General Public License (GPL)</h4>

<p>The GPL is arguably the granddaddy of them all. Matt boasted that 70% of Open Source projects use the GPL. However, it was astutely pointed out that this number is meaningless, as not all OS projects are created equal—only a few of them have significant userbase, longevity, and/or quality. A more reasonable metric would be to look at well known and proven projects. But even then, the GPL is strongly present.</p>

<p>The gist of the GPL is: if you change the code and release binaries, you also have to share your changes to the code. This is touted as the <em>free</em>-er of the licenses. The subtlety, however, is that it is freedom of the code, versus freedom of its user. To put code under the GPL is to ensure that everything it is used for has to be left open. This is a viral behaviour that has been known to scare some parties (or at least make them mildly uncomfortable).</p>

<h4>The BSD License</h4>

<p>The BSD license is the most lax of the three licenses. It is quite close to “here’s the code. Do what thou wilt.”</p>

<p>The simplicity is a point in its favour. Where the EPL and GPL weight over ten pages each, the BSD license is basically . . .</p>

<blockquote>

<p>Copyright (c) &#60;year&#62;, &#60;copyright holder&#62;All rights reserved.</p>

<p>Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:<br /> * Redistributions of source code must retain the above copyright<br /> notice, this list of conditions and the following disclaimer.<br /> * Redistributions in binary form must reproduce the above copyright<br /> notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.<br /> * Neither the name of the &#60;organization&#62; nor the<br /> names of its contributors may be used to endorse or promote products<br /> derived from this software without specific prior written permission.</p>

</blockquote>

<p>. . . plus a paragraph of details. Its brevity leaves little room for interpretation and ambiguity. This shines when contrasted to, for example, the EPL, where a contributor is redefined as a distributor. The thorny problem of redistribution (what exactly is redistribution? Does sharing your code with contractors fall under it?) is also a non-issue for this license.</p>

<h3>In Conclusion</h3>

<p>As mentioned above, there is no more point in declaring one license to be the “best one” than there would be to proclaim the supremacy of one kind of shoes over all others. Different circumstances just come with different criteria. To get quickly from point A to point B, you’ll want running shoes. To impress the crowd, stiletto heels are a better bet. Unless you sport a nicely trimmed beard, in which case I’d sooner recommend Oxfords.</p>

<p>The same thing goes for licenses. The trick is to know enough of the different options out there to make an informed decision when the time comes. Conveying that information was the primary goal of the event, and it delivered on it in a most excellent manner. And while a two-hour debate on pointed law matters had the very real potential to degenerate into a snore-a-thon, it managed to stay dynamic, alive, and pertinent for its whole length. For that, both the organizers and debaters deserve much credit.</p>

