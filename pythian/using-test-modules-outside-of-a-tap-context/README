---
title: Using test modules outside of a TAP context
url: using-test-modules-outside-of-a-tap-context
created: 2010-07-19
original: the Pythian blog - http://www.pythian.com/news/14519/using-test-modules-outside-of-a-tap-context
tags:
    - testing
    - Perl
    - TAP
    - Test::Wrapper
---
<p>I totally blame Tim Bunce for this one.</p>

<p>You see, I was happily minding my business today, until I got sight of Tim's tweet <a href="http://twitter.com/timbunce/status/18605698234">bemoaning the fact that Test::Difference tests can't easily be used outside of a test harness</a>. Darn him, that's exactly the kind of happy little puzzle I can't resist.</p>

<p>So I began to think about it. Of course, the Right Solution is probably to add alternative non-TAP-tied functions to the test modules themselves. But what if you just want to quickly leverage the module's functionality without having to re-arrange its innards? Well, most test modules use <code>Test::Builder</code>, so there's surely ways to twist that to our advantage. After a hour or two of hacking, I think I got one. </p>

<p>My little experience is named <code>Test::Wrapper</code>, and as usual can be found on <a href="http://github.com/yanick/test-wrapper">github</a>. In a nutshell, <code>Test::Wrapper</code> takes the tests that you want to use and gleefully bastardize the underlaying <code>Test::Builder</code> mechanisms such that nothing is output. Instead, the tests return an object that contains it all. </p>

<p>For example, if we want to use <code>eq_or_diff</code> from <code>Test::Differences</code>, we can do</p>

<pre code="perl">
    use 5.10.0;

    use Test::Differences;

    use Test::Wrapper qw/ eq_or_diff /;

    my $test = eq_or_diff &#34;foo&#34; =&#62; &#34;bar&#34;;

    say $test-&#62;is_success ? &#39;pass&#39; : &#39;fail&#39;;

    # yes! prints the whole diff table
    say &#34;output: &#34;, $test-&#62;diag;

    # also come with overloading voodoo

    say $test ? &#39;pass&#39; : &#39;fail&#39;;

    say &#34;output: $test&#34;;
</pre>

<p>As mentioned above, this comes with the price of totally messing up with <code>Test::Builder</code>, so using it intermixed with "real" tests is not an option. And it has doubtlessly a thousand gotchas I didn't think about. But, still, I must say that I like it despite (or because) its devious hijacking nature. I might even push it to CPAN it if proves to be useful to anyone (myself included).</p>

