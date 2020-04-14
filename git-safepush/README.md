---
title: Push... a little more than I ever wanted
url: git-safepush
format: markdown
created: 2011-01-11
tags:
    - Perl
    - git
    - git-safepush
    - Git::Wrapper
    - File::chdir
    - IO::All
    - List::MoreUtils
---

<div style="float: right; margin: 5px;"> 
<object width="360" height="288"><param name="movie"
value="http://www.youtube.com/v/vIWQhlUWWRQ?fs=1&amp;hl=en_US&amp;rel=0"/><param
name="allowFullScreen" value="true"/><param name="allowscriptaccess"
value="always"/><embed
src="http://www.youtube.com/v/vIWQhlUWWRQ?fs=1&amp;hl=en_US&amp;rel=0"
type="application/x-shockwave-flash" allowscriptaccess="always"
allowfullscreen="true" width="360" height="288" /></object>
</div>

Tell me if that sounds familiar: you're happily hacking on your codebase and,
at some point, you type in a password / secret token / really shameful limerick
that shouldn't be sent to the repository motheship, but that you 
need on your local copy. Well, no sweat, you just have to remember not to 
commit that specific file.  So hack, hack, hack go the fingers. Several hours
later, satisfied by your work, you commit the fruit of your labor and send it
to the master public repository. And, guess what? The file you were supposed
to remember not to commit? You didn't. And you did. Ooops.

Knowing how embarassingly failible my memory is, I looked for some 
automated safety net to use with Git.  The most obvious would have 
been to use a `push` hook, but alas Git has no such thing, and
if the [latest thread](http://kerneltrap.org/mailarchive/git/2008/8/19/2996404) I caught on the topic still hold, 
one isn't going to appear anytime soon. Since that venue is (for now) closed,
I turned to plan B: crafting a new git command, `git-safepush`:

<galuga_code code="Perl">git-safepush</galuga_code>

With that, I just had to add `DO NOT PUSH` in a comment line along
sensitive code, like so

```perl
# DO NOT PUSH
my $password = '$ecr3t';
```

and `safepush` is going to prevent me of doing anything foolish:

```bash
$ git safepush origin master:foo
'DO NO PUSH' seen in file 'MyConfig.pm', aborting push
```

