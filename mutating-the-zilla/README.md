---
created: 2012-03-26
tags:
    - Perl
    - Dist::Zilla
    - Moose
---

# Mutating the Zilla

By now, I have a few [Dist::Zilla](cpan) plugins interacting with the
distribution's changelog. Each time, I get the changelog, I parse it into a
[CPAN::Changes](cpan) object, do something to it and save it again. It's
actually not even as hard as it sounds:

```perl
sub munge_files {
    my ($self) = @_;

    my ($file) = grep { $_->name eq $self->change_file } 
                        @{ $self->zilla->files };
    return unless $file;

    my $changes = CPAN::Changes->load_string( $file->content, 
        next_token => qr/{{\$NEXT}}/
    );

    my ( $next ) = reverse $changes->releases;
    $next->add_changes( 'hi there' );

    $self->log_debug([ 'updating contents of %s in memory', 
        $file->name ]);
    $file->content($changes->serialize);
}
```

Not hard at all, but it's still repetitive. Of course, I could factor most of it away by
creating a role that I would apply to the plugins. That would be the
reasonable way to go. But... what if we could percolate that one level up the food
chain and inject the changelog behavior on the `zilla` object itself? Let's
forget for a second the moral aspect of the thing, and see if such a feat
would be possible, without directly touching any of the core `Dist::Zilla` code.

First, we would need the plugin to tell us which `Dist::Zilla` roles they need
to function. Something like

    #syntax: perl
    package Dist::Zilla::Plugin::ChangeStats::Git;
    use Moose;

    # regular stuff
    with qw/
        Dist::Zilla::Role::Plugin
        Dist::Zilla::Role::FileMunger
    /;

    # roles we need our master zilla to have
    with 'Dist::Zilla::Role::Author::YANICK::RequireZillaRole' => {
        roles => [ qw/ Author::YANICK::Changelog / ],
    };

With that, now we just need that `RequireZillaRole` to take those roles and
apply them to our *$zilla*.

    #syntax: perl
    package Dist::Zilla::Role::Author::YANICK::RequireZillaRole;

    use Module::Load;

    use MooseX::Role::Parameterized;

    parameter roles => (
        required => 1,
    );

    role {
        my $p = shift;

        sub BUILD {}

        after BUILD => sub { 
            my $self = shift;

            my $zilla = $self->zilla;

            # open the patient...
            $zilla->meta->make_mutable;

            for my $role ( 
                        grep { ! $zilla->does($role) }
                        map  { 'Dist::Zilla::Role::'.$_ } 
                             @{ $p->roles } ) {
                load $role;
                $role->meta->apply($zilla->meta)
            }

            # ... and close the patient
            $zilla->meta->make_immutable;

            return $self;
        }
    }

The general framework is done.  Now, the main tricky thing to remember is
that even though we have shiny new zilla attributes, not all plugins will be
aware of them. In our example, with the changelog, this means that we have to
ensure that the changes and reflected in its file once every plugin is done
with it.  Which can be done as follow:

```perl
package Dist::Zilla::Role::Author::YANICK::Changelog;

use List::Util qw/ first /;
use CPAN::Changes;

use Moose::Role;

has changelog => (
    is => 'ro',
    lazy => 1,  # required here because of the after-the-fact role
    default => 'Changes',
);

has changelog_file => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return first { $_->name eq $self->changelog } @{ $self->files };
    },
);

has changes => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        return CPAN::Changes->load_string( 
            $self->changelog_file->content, 
            next_token => qr/{{\$NEXT}}/
        );
    }
);

sub save_changelog {
    my $self = shift;
    $self->changelog_file->content($self->changes->serialize);
}

before build_in => sub {
    my $self = shift;

    for my $plugin ( @{ $self->plugins_with(-FileMunger) } ) {
        $plugin->meta->make_mutable;
        $plugin->meta->add_after_method_modifier('munge_files', sub { 
            my $self = shift;
            $self->zilla->save_changelog;
        });
        $plugin->meta->make_immutable;
    }
}

1;
```


So, to recap: in our plugins we are using a role that inject roles in the main
zilla object, which in turn are likely to turn around and modify plugin
behaviors. Pretty straight-forward, isn't?  But with this, the first snippet
above is now reduced to 

    #syntax: perl
    with 'Dist::Zilla::Role::Author::YANICK::RequireZillaRole' => {
        roles => [ qw/ Author::YANICK::Changelog / ],
    };

    sub munge_files {
        my ($self) = @_;

        my ( $next ) = reverse $self->zilla->changes->releases;
        $next->add_changes( 'hi there' );
    }

In bonus, we now also have the
possibility to make all changelog-related configurations central.

This being said, I'm still unsure if I'm on my way to become a meta-lord, or 
if I just won myself a very special place in the 8th circle of Hell, where
Monkeypatchers go when they die. But, in all cases, if you are curious,
[Dist::Zilla::Plugin::ChangeStats::Git](https://github.com/yanick/Dist-Zilla-Plugin-ChangeStats-Git),
which was the main guinea pig for this strange experiment, is up on GitHub for
your vivisecting pleasure.
