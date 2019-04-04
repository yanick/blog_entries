---
title:             XPathScript Reborn
url:            xpathscript-reborn
format:         html
created:         7 Jul 2010
last_update:    2 Aug 2010
original:         the Pythian blog - http://www.pythian.com/news/14007/xpathscript-reborn
tags:
    - Perl
    - XML
    - XML::XSS
    - XML::XPathScript
---

<p>A long, long time ago, Matt Sergeant (of SpamAssassin fame) came up with an XML application server for Apache called <a href="http://axkit.org">AxKit</a>. It was quite nifty, and offered many ways to transform XML documents. One of them was an home-brewed stylesheet language called XPathScript, which very quickly caught my fancy. It had a very Perlish way of doing things and was feeling infinitely more ergonomic to me than, say, the visual tag-storm that is XSLT. So, quite naturally, it was not long before I found myself wanting to use it not only in the context of an AxKit, but as a generic XML transformer. A little hacking happened to decouple the core engine from its Apache roots, and <a href="http://search.cpan.org/~yanick/XML-XPathScript">XML::XPathScript</a> was born.</p>

<p>That module served me quite well throughout the years, but for some time now I’ve had this plan of doing a clean rewrite patiently sitting on my back-burner. There are a few new features that I wanted to wedge in (an easier, cleaner way to create and extend stylesheets, a way for the transformation elements to pass information back and forth), and other infrastructure details (like the way the current XPathScript definition of ‘template’ and ’stylesheet’ is the inverse of what one would expect). But, of course round tuits are rare, and that project lingered…</p>

<p>… but lingers no more. This week I had a smashing <a href="http://en.wikipedia.org/wiki/Staycation">staycation</a>, and thanks to a very understanding wife, I was able to indulge in the necessary hacking sessions to get the ground work done. The result is not on CPAN yet, but can be perused on <a href="http://github.com/yanick/xml-xss">GitHub</a>.</p>

<p>As an example is worth a thousand pages of documentation, let’s say that you want to turn the piece of docbook-ish xml</p>

<pre class="brush: xml;">
&#60;section title=&#34;Introduction&#34;&#62;
&#60;para&#62;This is the first paragraph.&#60;/para&#62;
&#60;para&#62;And here comes the second one.&#60;/para&#62;
&#60;/section&#62;
</pre>

<p>into the html</p>

<pre class="brush: xml;">
&#60;h1&#62;Introduction&#60;/h1&#62;
&#60;p class=&#34;first_para&#34;&#62;This is the first paragraph.&#60;/p&#62;
&#60;p&#62;And here comes the second one.&#60;/p&#62;
</pre>

<p>Here a XML::XSS script that will do the trick:</p>

<pre class="brush: perl;">
use XML::XSS;

my $xss = XML::XSS-&#62;new;

$xss-&#62;set(
    section =&#62; {
        showtag =&#62; 0,
        intro   =&#62; sub {
            my ( $self, $node ) = @_;
            $self-&#62;stash-&#62;{seen_para} = 0;    # reset flag
            return &#39;&#60;h1&#62;&#39; . $node-&#62;findvalue(&#39;@title&#39;) . &#39;&#60;/h1&#62;&#39;;
        },
    } );

$xss-&#62;set(
    para =&#62; {
        pre   =&#62; &#39;&#60;p&#62;&#39;,
        post  =&#62; &#39;&#60;/p&#62;&#39;,
        process =&#62; sub {
            my ( $self, $node ) = @_;

            $self-&#62;set_pre(&#39;&#60;p class=&#34;first_para&#34;&#62;&#39;)
                unless $self-&#62;{seen_para}++;

            return 1;
        },
    } );

print $xss-&#62;render( &#60;&#60;&#39;END_XML&#39; );

&#60;doc&#62;
    &#60;section title=&#34;Introduction&#34;&#62;
    &#60;para&#62;This is the first paragraph.&#60;/para&#62;
    &#60;para&#62;And here comes the second one.&#60;/para&#62;
    &#60;/section&#62;

&#60;/doc&#62;
END_XML
</pre>

<p>The code is still very young and has more bugs that I dare to count, but it’s getting to the point where it’s usable. The next things that are on my plate are:</p>

<ul><li>

<p>Make the documentation suck less.</p>

 </li><li>

<p>Re-introduce the templates. So that </p>

 </li> </ul><pre class="brush: perl">
$xss-&#62;get(&#39;section&#39;)-&#62;set_intro( sub {
    my ( $self, $node ) = @_;
    $self-&#62;stash-&#62;{seen_para} = 0;    # reset flag
    return &#39;&#60;h1&#62;&#39; . $node-&#62;findvalue(&#39;@title&#39;) . &#39;&#60;/h1&#62;&#39;;
} );
</pre>

<p>can become</p>

<pre class="brush: perl">$xss-&#62;get(&#39;section&#39;)-&#62;set_intro( xsst q{
    &#60;% $r-&#62;stash-&#62;{seen_para} = 0; %&#62;
    &#60;h1&#62;&#60;%@ @title %&#62;&#60;/h1&#62;

} );
</pre><ul><li>

<p>Re-introduce the command-line transforming command.</p>

 </li><li>

<p>Add the ability to use XPath expressions as rendering rules.</p>

 </li><li>

<p>And much, much more…</p>

 </li> </ul> 
