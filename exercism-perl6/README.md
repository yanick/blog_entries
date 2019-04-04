---
created: 2015-10-19
---

# Exercism.io and Perl6(66)

[Exercism.io](http://exercism.io/) is a neat site where 
you can download small programming exercises in dunnamany languages, and then 
publish them to be reviewed by your peers. And,
guess what?, although it's not listen as one of the active languages, Perl6 is
there, carefully hiding in the shadows. 

Assuming you start from scratch and want to join the fun and practice your
Perl6-fu, here's what you have to do:

1. Go to the [exercism.io](http://exercism.io/) site and log on (you can use
your twitter account to authenticate).

2. Install the *go* cli command following the [site's
instructions](http://help.exercism.io/installing-the-cli.html).

3. Init the environment on your machine (the API key will be found on your
[account page](http://exercism.io/account).

```
$ exercism configure --key=dedbeefdeadbeefdeadbeef
The configuration has been written to /home/yanick/.exercism.json
Your exercism directory can be found at /home/yanick/exercism
```

4. Summon a first exercise.

```
$ exercism fetch perl6
```

If all went well, you should now have a directory `~/exercism/perl6/bob`,
populated by a README as well as a `bob.t` test file. 

5. Write your solution to the challenge, and then submit it back to the site to get your next one.

```
$ exercism submit Bob.pm
```

Now repeat (4) and (5) until Perl6 enlightment ensues.

By the by, I am [yanick](http://exercism.io/yanick) on Exercism.io. Feel free
to come and judge my exercises as you wish.

And finally, the number of the site's exercises translated into Perl6 is
rather low (11 at last count).  But that's something easily fixed, as the
exercises's repository is [on GitHub](https://github.com/exercism/xperl6). 
Try not to peek while you're still working on the exercises that are already
there ('cause that would be cheating. And cheating is bad), but once you're
done, consider trying your hand at implementing the site's other programming
challenges (you can take the [Perl5 repo](https://github.com/exercism/xperl5)
as an example), or improving on the test files themselves -- some of them
implement only a subset of the tests that are there for Perl5.

Oh yeah, and if you want an easy way to submit the current exercise and fetch
the next one, I [wrote a small
script](https://github.com/yanick/environment/blob/master/bin/vaderetro) a wee while ago that does exactly
that.

Enjoy!

