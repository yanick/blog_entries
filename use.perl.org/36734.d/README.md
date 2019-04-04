---
format: html
created: 19 Jun 2008
original: use.perl.org - http://use.perl.org/~Yanick/journal/36734
tags:
    - Perl
    - Test::Class
    - Test::Group
---

# Test::Class + Test::Group

<p>
I've been playing with
<a href="http://search.cpan.org/~adie/Test-Class/" rel="nofollow">Test::Class</a>
lately and,
I must say, it's a heck of a nice module. Only thing that
I wish it had is the possibility to report each test as
a single pass/failure, no matter the number of assertions
done in the function.  Just like
<a href="http://search.cpan.org/~domq/Test-Group" rel="nofollow">Test::Group</a> does.</p><p>Hmmm... But wait a second.  Could it be possible to somehow stuff the
caramel-like sweetness of Test::Group in the smooth chocolatey
wrapping of Test::Class? Turns out that yes, it's perfectly possible! And
even more, without even having to muck with the guts of either
modules:</p><blockquote><div><p> <pre>package Some::TestSuite;
 
use base qw/ Test::Class<nobr> <wbr></wbr></nobr>/;
use Test::Group;
use Test::More;
 
sub Test<nobr> <wbr></wbr></nobr>:ATTR(CODE,RAWDATA) {
   my ( $pkg, $funct, $code ) = @_;
 
   no warnings;  # black magic starts here
 
   my $func_name = *{$funct}{NAME};
   my $fullname = $pkg.'::'.$func_name;
 
   *{$funct} = sub {
       print "begin test [", scalar localtime, "]\n";
       Test::Group::test( $fullname => \&amp;{$code} );
       print "end test [", scalar localtime, "]\n";
   };
 
   Test::Class::Test( @_ );
}
 
sub aTest : Test {
    ok 1, 'eins';
    ok 1, 'zwei';
    ok 1, 'drei';
}
 
sub otherTest : Test {
    ok 1, 'un';
    ok 0, 'deux';
    ok 1, 'trois';
}
 
Some::TestSuite->runtests;</pre></p></div> </blockquote><p>Which
gives</p><blockquote><div><p> <pre>$ perl test.t
1..2
begin test [Thu Jun 19 22:17:16 2008]
ok 1 - Some::TestSuite::aTest
end test [Thu Jun 19 22:17:16 2008]
begin test [Thu Jun 19 22:17:16 2008]
#   Failed test 'deux'
#   in a.t at line 32.
not ok 2 - Some::TestSuite::otherTest
#   Failed test 'Some::TestSuite::otherTest'
#   at a.t line 17.
#   (in Some::TestSuite->otherTest)
end test [Thu Jun 19 22:17:16 2008]
# Looks like you failed 1 test of 2.</pre></p></div> </blockquote><p>This method, though, has two modest caveats:</p><ol>
<li>A failed assertion will be given with the correct line,
    but the test itself will be reported as being located inside
    the Test() function.</li><li>Test fixtures have to be declared as having 1 test (i.e.,
it has to be <i>sub mySetup<nobr> <wbr></wbr></nobr>:Test(setup => 1) {<nobr> <wbr></wbr></nobr>.. })</i></li></ol>
