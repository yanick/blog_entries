---
created: 2021-06-07
tags:
    - File::Serialize
    - blog
---

# Serial Killer App

<div style="float: right; padding: 5px;">
<img src="/val_approuve.png" alt="New and Improved!" width="300"/>
</div>


I was in a conversation where [Brian Wisti](https://randomgeekery.org/)
was showing how he's bandying around data between
[Taskwarrior](https://taskwarrior.org/), 
[Obsidian](https://obsidian.md/) and [logseq](https://logseq.com/), flipping
things between JSON and Markdown with frontmatter. I was
nodding along, agreeing that Markdown with frontmatter is really a 
sweet spot between easily parsed data and a human-consumable document. Indeed,
I often slurp in those files and split the frontmatter and content and...

Wait a second... Yeah, I do that all the time. Granted, it's not a lot of work.
Like, it's pretty much

```perl
my ( $frontmatter, $content ) = split /^---\n$/, $markdown, 2;
$frontmatter = YAML::Load($frontmatter);
```

but still. If only there was a module that took care of
serializing/deserializing files, and if only it grokked Markdown.

Oh, wait, there is such a thing: [File::Serialize](https://metacpan.org/pod/File::Serialize). And now it does grok Markdown.

```
⥼ transerialize ./README.md -.json
{
   "_content" : "\n# Serial Killer App\n\nI was[...]",
   "created" : "2021-06-07",
   "tags" : [
      "File::Serialize",
      "blog"
   ]
}
```

## Transforming scriptlets

That got me thinking. As I was rambling about in my earlier 
talks of this month, the source files of my blog are Markdown-based,
with a couple of extra-special features (I mean, y'all know me, right? That's
hardly a surprise, right?). To turn those sources in canonical Markdown (well,
actually, [MDSvex](https://mdsvex.com/)), I'm passing it through a Perl script
that munges it just so. It'd be nice to split that script into its functional
components.

If I was using `transerialize` in its "function of `File::Serialize`"
incarnation, I could do that easily. As of last week, the command-line
utility could only take snippets of code. Cute, but getting unwieldy real
fast. But now the intermediary steps also take in filenames of Perl script
assumed to return a transforming function. 

Which means that, say I want to gather the blog entry title from the content,
and want to add a slug:

```perl
# ./set_front_title.pl

$File::Serialize::implicit_transform = 1;

sub {
    return if $_->{title};

    $_->{title} = $1 if $_->{_content} =~ /^# (.*)/m;
}
```

```perl
# ./set_slug.pl

$File::Serialize::implicit_transform = 1;

use Path::Tiny;

sub {
    $_->{slug} = path($File::Serialize::SOURCE)
                    ->absolute->parent->basename;
}
```

And then 

```bash
⥼ transerialize ./README.md ./set_front_title.pl ./set_slug.pl -.json

{
   "_content" : "...",
   "created" : "2021-06-07",
   "slug" : "serial-killer-app",
   "tags" : [
      "File::Serialize",
      "blog"
   ],
   "title" : "Serial Killer App"
}
```

## Herding scriptlets

Nice! But if there are to be more than a few transforming steps, the command
line is going to be huge. If only we could, I don't know, put the list
of scriptlets in a serialized config file, and auto-expand that on demand?

Well, now we can do that too. In this example I'm using YAML because 
I love it, but as you may surmise, `File::Serialize` uses `File::Serialize`
to deserialize the file, so any supported format can be used there.

```
# ./transform.yml
- ./set_front_title.pl
- ./set_slug.pl
```

and then...

```bash
⥼ transerialize ./README.md @./transform.yml -.json

{
   "_content" : "...",
   "created" : "2021-06-07",
   "slug" : "serial-killer-app",
   "tags" : [
      "File::Serialize",
      "blog"
   ],
   "title" : "Serial Killer App"
}
```

