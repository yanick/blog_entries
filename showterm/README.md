---
created: 2015-09-18
---

# That will Showterm

A lot of my blog entries are show'n'tell of stuff that I do. Beyond presenting
the code, it's always fun to also showcase the end-result. Usually, that's
done via screenshots. Which is a serviceable way of doing it, but it's
rather... static. If you want to capture the imagination of your audience, you
want to hook them with action, with movement, with drama. You
want them to feel like they're watching a live demo.

Of course, there are many ways to record a movie of one's desktop, but for 
a lot of things like cli examples, that rather feel like heavy overkill. There
is, however, a midway solution. [showterm.io](https://showterm.io/) is a web
service that takes in a recording produced by the UNIX tool [script](http://man7.org/linux/man-pages/man1/script.1.html|script)
and present a JavaScript-powered version of it. It's awesome, and I've used it
in the past for this very blog. But I've always
been bothered by the fact that I rely on an external service for the playback
of those recording. So I finally decided to do something about it. I cloned
the repository, distilled the necessary JavaScript and stylesheet from it,
and... say hello to [](cpan:Dancer-Plugin-Showterm), which gives any Dancer
app the power to play back script recordings.

And how easy it is to record your terminal, you ask? Here, let me show you:

<iframe src="./showterm.showterm" class="showterm">
</iframe>






