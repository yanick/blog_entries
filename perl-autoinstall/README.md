---
created: 2017-03-28
---

# Quick Quack Hack: perl-autoinstall

Tell me if this sounds familiar: you try to run a Perl script, and
it barfs because it lacks a dependency. So you install the said dependency,
run the script again only to have it stumble on the next dependency.
And so on, and so forth for waaaay too long.

Now, I could try to fix that by analyzing the script, try
to figure out which modules are `use`d and pipe that all to `cpanm`.
Or... or I just could be a brute and delegate that boring 
try-install-try-again loop to a script. After all, computers *love* loops.

So say hello to
[perl-autoinstall.fish](https://github.com/yanick/environment/blob/master/fish/functions/perl-autoinstall.fish).

```
function perl-autoinstall

    set deps dummy

    while true;
        set prev_deps $deps

        set output ( perl $argv 2>&1 )
        echo $output

        set deps ( echo $output | perl -nE'say $1 if /you may need to install the (\S+) module/' )

        if test -z $deps
            break
        end

        if test $deps = $prev_deps
            echo "dependencies didn't change"
            break
        end

        echo $deps | cpanm -n
    end;

end
```

The logic is simple. Run 

```
$ perl-autoinstall the_script_of_a_thousand_dependencies.pl
```

and `perl-autoinstall` will try to run the script. If it fails
with the dependency error we all dread, it'll run `cpanm` to install
it, then try again. And just to protect ourselves of infinite loops that
a uninstallable dependency would cause, we stop trying if we hit the same
dependency twice in a row. Nothing really elegant, but then again, when one
plows through dependencies, one doesn't elegance. One needs stubborn
determination, and this this script delivers that in spade.

Also, I've used a fish shell script, because I roll that way, but it would be
pretty easy to convert that to bash, perl or whatever else one might fancy.

Enjoy!

