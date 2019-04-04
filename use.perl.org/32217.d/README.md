---
format: html
created: 20 Jan 2007
original: use.perl.org - http://use.perl.org/~Yanick/journal/32217
tags:
    - Perl
    - XML::XPathScript
---

# XML::XPathScript 1.47 is out

<p>It is with great relish that I announce that XML::XPathScript v1.47 is on its way to a CPAN mirror near you.</p><p>[ ED: Do'h! The test that was supposed to gracefully skip if B::XPath isn't installed bombs instead. (blame it on my naive assumption that   'eval { use B::XPath; 1 }' would work). I'll do a s/use/require/ on that test and release 1.48 tonight. ]</p><p>What is new in this release:</p><p>* template tag attributes can now be functions as well as strings.</p><p>
        For example,</p><p>
                $template->set( 'foo' => { testcode => sub {<br></br>
                                my( $n, $t ) = @_;<br></br>
                                my $name = $n->findvalue( 'name()' );<br></br>
                                $t->set({ pre => transfurbicate( $name ) });<br></br>
                                return $DO_SELF_AND_CHILDREN;<br></br>
                        }<br></br>
                } );</p><p>
        can now be written</p><p>
                $template->set( 'foo' => { pre => sub {<br></br>
                                my( $n, $t ) = @_;<br></br>
                                my $name = $n->findvalue( 'name()' );<br></br>
                                return transfurbicate( $name );<br></br>
                        }<br></br>
                } );</p><p>* The 'content' template attribute, which associates template elements to<br></br>mini-stylesheets.</p><p>
        E.g., the code</p><p>
        &lt;%<br></br>
                $template->set( 'foo' => {<br></br>
                                pre => '<newFoo foo_myattr="{@myattr}" >',<br></br>
                                post => '</newFoo>',<br></br>
                                action => 'bar',        # only process 'bar' node children<br></br>
                } );<br></br>
        %></p><p>
                can now be written</p><p>
        &lt;%<br></br>
                $template->set( 'foo' => { content => &lt;&lt;'END_CONTENT' } );<br></br>
                        <newFoo foo_myattr="{@myattr}" >  &lt;%# look Ma, we interpolate! %><br></br>
                                &lt;%~ bar %>                    &lt;%# only process bar children %><br></br>
                        </newFoo><br></br>
        END_CONTENT<br></br>
        %><br></br>
        &lt;%# process all foo's %><br></br>
        &lt;%~<nobr> <wbr></wbr></nobr>//foo %></p><p>
        Or, to be more easy on the eye, we can use the short-hand version:</p><p>
        &lt;%@ foo<br></br>
                <newFoo foo_myattr="{@myattr}" >  &lt;%# look Ma, we interpolate! %><br></br>
                        &lt;%~ bar %>                    &lt;%# only proces bar children %><br></br>
                </newFoo><br></br>
        %><br></br>
        &lt;%# process all foo's %><br></br>
        &lt;%~<nobr> <wbr></wbr></nobr>//foo %></p><p>* B::XPath now a supported DOM tree. Bored with transforming XML documents?<br></br>How about transforming Perl Optrees?<nobr> <wbr></wbr></nobr>:-)</p><p>
                use B::XPath;<br></br>
                use XML::XPathScript;</p><p>
                sub guinea_pig {<br></br>
                        my $x = shift;<br></br>
                        print "oink oink " x $x;<br></br>
                }</p><p>
                my $xps = XML::XPathScript->new;</p><p>
                $xps->set_dom( B::XPath->fetch_root( \&amp;guinea_pig ) );</p>
<p>
                $xps->set_stylesheet( '&lt;%~ //print %>' );</p><p>
                print $xps->transform;
</p>
