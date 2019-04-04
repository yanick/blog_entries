---
created: 2011-04-10
tags:
    - Perl
    - Dist::Zilla
    - semantic versions
    - CPAN::Changes
---

# A Semantic Version Plugin for Dist::Zilla

These days, I try to give a [semantic logic 
to the version numbers][2] of my distributions:
bug fixes increment the revision number (e.g., 
`1.2.3` => `1.2.4`,
added functionality increments the minor
version number (`1.2.3` => `1.3.0`) and an api change increments
a major version number (`1.2.3` => `2.0.0`).  


*caveat emptor:* last time I checked the general concensus of the greater 
Perl community was leaning
more toward  single-dot version notation 
instead of the double-dot (`1.002003` instead of `1.2.3`). But for the 
good of this blog entry, that's only a formatting issue -- the underlaying logic
applies to any numbering scheme allowing different levels of
incrementation.

Back when I was playing with [Dist::Release](cpan),
I came up with [a semi-automated way of incrementing
the version number of the distribution][1], but that fell on
the wayside when I switched to [Dist::Zilla](cpan).  
With `Dist::Zilla`, so far I was manually setting up the new version 
number in the `dist.ini` of my distributions. But, as I'm a lazy, lazy man, 
automating the process was still at the back of my mind. Moreso after
[CPAN::Changes](cpan) appeared, as the module makes the whole endeavor
much easier by both providing concrete specifications on the format of the
changelog, and a clear api to query and modify it. 

Well, today I finally found the time to work on this. The result is
`Dist::Zilla::Plugin::Author::YANICK::NextSemanticVersion`, which
currently lives in the [Dist::Zilla::PluginBundle::YANICK](cpan)
distribution (and, of course, in its [GitHub repository][3]).

[1]: http://babyl.dyndns.org/techblog/entry/per%28l%29version
[2]: http://semver.org/
[3]: https://github.com/yanick/Dist-Zilla-PluginBundle-YANICK

This new plugin mostly piggyback on `Dist::Zilla::Plugin::NextRelease`
and trails its wake to add the few extra behaviors we want. For a new
'`{{$NEXT}}`' entry, in addition to the version head line 
it inserts the different types of changes we can have:

```
{{$NEXT}} 
[API CHANGES]

[BUG FIXES]

[ENHANCEMENTS]
```

This way, we never have to remember what is our different types, as they all
are explicitly given. But, of course, we don't want the visual noise
of empty groups in our final changelog, so we also have our plugin strip
back empty groups in the built changelog. Thanks to `CPAN::Changes`, all
that juggling is done rather painlessly:

```perl
    # triggered after the release step
    sub after_release {
        my $self = shift;

        my $changes = CPAN::Changes->load( 
            $self->filename, 
            next_token => qr/{{\$NEXT}}/ 
        ); 

        # clean empty groups all around
        for my $r ( $changes->releases ) {
            for my $g ( $r->groups ) {
                $r->delete_group($g) unless @{ $r->changes($g) };
            }
        }

        # ... but put back a template for the $NEXT release
        my ( $next ) = reverse $changes->releases;
        $next->add_group( @major_groups, @minor_groups, @revision_groups );

        $self->log_debug([ 'updating contents of %s on disk', $filename ]);

        open my $out_fh, '>', $self->filename or die $!;
        print $out_fh $changes->serialize;
    }

    # triggered at the file munging step
    sub munge_files {
        my $self = shift;

        my ($file) = grep { $_->name eq 'Changes' } @{ $self->zilla->files }
            or return;

        my $changes = CPAN::Changes->load_string( $file->content, 
            next_token => qr/{{\$NEXT}}/
        );

        my ( $next ) = reverse $changes->releases;

        # empty groups only for the work copy
        $next->delete_group(
            grep { !@{$next->changes($_)} } $next->groups 
        );

        $self->log_debug([ 'updating contents of %s in memory', $file->name ]);
        $file->content($changes->serialize);
    }
```

With that done, the other part of functionality that is missing is the 
version increment itself. For that, I simply let myself be heavily 
inspired by [Dist::Zilla::Plugin::Git::NextVersion](cpan) in its
implementation of the `VersionProvider`'s role:

```perl

    # for the VersionProvider role
    sub provide_version {
        my $self = shift;

        my $git  = Git::Repository->new( work_tree => '.');
        my $regexp = $self->version_regexp;

        # TODO actually, should be after the next stanza
        my @tags = $git->run('tag') or return $self->first_version;

        # find highest version from tags
        my ($last_ver) =  
            sort { version->parse($b) <=> version->parse($a) }
            grep { eval { version->parse($_) }  }
            map  { /$regexp/ ? $1 : ()          } @tags;

        $self->log_fatal("Could not determine last version from tags")
            unless defined $last_ver;

        my $new_ver = $self->next_version($last_ver);

        $self->zilla->version("$new_ver");
    }

    sub next_version {
        my( $self, $last_version ) = @_;

        my ($changes_file) = grep { $_->name eq $self->filename } @{ $self->zilla->files };

        my $changes = CPAN::Changes->load_string( $changes_file->content,
            next_token => qr/{{\$NEXT}}/ ); 

        my ($next) = reverse $changes->releases;

        my $new_ver = $self->inc_version( 
            $last_version, 
            grep { scalar @{ $next->changes($_) } } $next->groups
        );

        $self->log("Bumping version from $last_version to $new_ver");
        return $new_ver;
    }

    sub inc_version {
        my ( $self, $version, @groups ) = @_;

        $version = Perl::Version->new( $version );

        if ( grep { $_ ~~ @groups } @major_groups ) {
            $version->inc_revision;
            return $version
        }
            
        for ( grep { $_ ~~ @groups } @minor_groups ) {
            $version->inc_version;
            return $version
        }

        $version->inc_subversion;
        return $version;
    }
```

And that's it. All that I'm left to do is to 
enter my changes under the correct groups, and the
plugin will take care of both correctly 
incrementing the version number and tidying the changelog
before the a release.
