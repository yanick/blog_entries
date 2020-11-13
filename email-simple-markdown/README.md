---
url: email-simple-markdown
created: 2012-05-16
tags:
    - Perl
    - Email::Simple::Markdown
---

# Easy text/html multipart emails with Email::Simple::Markdown

These days, to craft basic emails, I go with [Email::Simple](cpan). For
the more heavy stuff with attachements and what-nots, I reach out for 
[Email::MIME](cpan). Together, they make a pretty awesome duo. But...
(come on, admit it, you knew there was going to be a 'but')

But there is a fairly common use-case that falls pretty much squarely
between those two modules. To wit: creating multipart emails that have two 
versions of the same body: one that is normal, boring pure text,
and the other that is pretty html. *Email::Simple* does not support multipart
bodies (because, after all, it's meant to be simple), so it cannot help me
there.  *Email::MIME*, though, is perfectly up for the job:


```perl
use Email::MIME;

my $email = Email::MIME->create(
    attributes => {
        content_type => 'multipart/alternative',
    },
    header_str => [
        From    => 'me@here.com',
        To      => 'you@there.com',
        Subject => q{Here's a multipart email},
    ],
    parts => [
        Email::MIME->create(
            attributes => { content_type => 'text/plain' },
            body => 'Howdie',
        ),
        Email::MIME->create(
            attributes => { content_type => 'text/html' },
            body => '<b>Howdie</b>',
        )
    ],
);

say $email->as_string;
```

It's not atrocious, but it's not lightweight either. And there is the problem
that one has to make the effort to keep both bodies in sync. For simple
emails, it would make much more sense to have a single source for the body,
and generate both renditions off it. For that kind of thing, [Markdown](http://daringfireball.net/projects/markdown/) served
me well in the past, so why not use it. To my great pleasure, I found out that 
[Email::MIME::Kit::Assembler::Markdown](cpan) already exist. Alas, it's
also quite more heavy that, for the user-case at hand, I would care for.  

So I created [Email::Simple::Markdown](cpan).  (again, raise your hand if
you didn't see that coming)

It inherits from
*Email::Simple*, and all it does is to generate the multipart message out of
an original pure-text body via the goodness of [Text::MultiMarkdown](cpan).
Nothing arcane, but with it the code above can now be reduced to:

```perl
use Email::Simple::Markdown;

my $email = Email::Simple::Markdown->create(
    header => [
        From    => 'me@here.com',
        To      => 'you@there.com',
        Subject => q{Here's a multipart email},
    ],
    body => '**Howdie**',
);

say $email->as_string;
```

which, I daresay, is much easier on the eyes.
