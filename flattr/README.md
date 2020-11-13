---
url: flattr
created: 2013-04-07
tags:
    - Perl
    - Flattr
---

# Flattr your CPAN Stack

Today I caught brian d foy's [Crowdtilt campaign for
Pinto](https://www.crowdtilt.com/campaigns/specify-module-version-ranges-in-pint/contributors)
on Twitter, and it triggered an old thought that I had. Wouldn't it be nice to
be able to gather information about the CPAN stack you're using and throw a
few pennies in the tipjars of all the authors involved? So I decided to have a
(oh so very) quick go at it.

## First Step: Gather The Stack

For simplicity, I assume here that the module management is done via
[Pinto](cpan). If not, one can always do similar shenanigans via
CPAN autobundling (`cpan -a`). But, in all cases, with `Pinto` the gathering
can be done via:

```perl
#!/usr/bin/env perl

use 5.10.0;

use strict;
use warnings;

use Pinto::Schema;
use YAML qw/ LoadFile DumpFile/;

my $schema = Pinto::Schema->connect(
    'dbi:SQLite:/path/to/your/pinto.db' );

my $author = -f 'STACK.yml' ? LoadFile( 'STACK.yml' ) : {};

# clear previous data
$_->{dists} = [] for values %$author;

my $rs = $schema->resultset('Distribution');

while( my $p = $rs->next ) {
    push @{ $author->{$p->author_canonical}{dists} }, $p->archive;
}

DumpFile('STACK.yml', $author);
```

## Second Step: Link authors to micropayment accounts

I picked [Flattr](http://flattr.com) as the micropayment platform here
mostly because MetaCPAN accounts already have the hook for it. And that makes
things veeeery easy on me:

```perl
#!/usr/bin/env perl 

use 5.10.0;

use strict;
use warnings;

use MetaCPAN::API;
use YAML qw/ LoadFile DumpFile/;

my $authors = -f 'STACK.yml' ? LoadFile( 'STACK.yml' ) : {};

my $mcpan = MetaCPAN::API->new;

for my $id ( keys %$authors ) {
    my $author = $mcpan->author($id) or next;
    my @profiles = @{$author->{donation} or next};
    next unless @profiles;
    my( $flattr ) = grep { $_->{name} eq 'flattr' } @profiles;
    next unless $flattr;
    next unless $flattr->{id};
    $authors->{$id}{flattr} = $flattr->{id};
}

DumpFile('STACK.yml', $authors);
```


Fair warning: this script will do a request for each author to the metaCPAN
API. So if you ever use it, be kind and pace yourself. And don't run it every
5 minutes.

By now, we have all the information we need in the `STACK.yml` file, which
will look something like:

```yaml
---
XSAWYERX:
dists:
    - Dancer-1.3110.tar.gz
    - Dancer-Plugin-Authorize-1.110720.tar.gz
    - Dancer-Plugin-Auth-RBAC-1.110720.tar.gz
YANICK:
dists:
    - Dancer-Plugin-Cache-CHI-1.4.0.tar.gz
    - Dancer-Plugin-MobileDevice-0.04.tar.gz
flattr: yenzie
```

## Third Step: Flattr ALL THE THINGS!

Sounds easy, but that's the part that is the most finicky. Flattr, you see, 
use OAuth2, which is a little hard on the brain (and doesn't seem to play nice
with desktop applications).  Plus, I didn't find (yet)
a way to flattr an email address directly. So, in the name of Proof of
Conceptitude, I decided to play quick and dirty and create a pseudo-web app
for the occasion: 

```perl
package FlattrCPANStack;
use Dancer ':syntax';

use 5.10.0;

use strict;
use warnings;

use Net::OAuth2::Profile::WebServer;
use JSON qw/ encode_json/;
use YAML qw/ LoadFile /;

my $auth = Net::OAuth2::Profile::WebServer->new
( name           => 'Flattr'
, client_id      => 'get one at https://flattr.com/apps/new'
, client_secret  => 'see --^'
, site           => 'https://flattr.com'
, authorize_path    => '/oauth/authorize'
, access_token_path => '/oauth/token'
, scope => 'flattr'
);

# NOTE: set the callback on the flattr app config 
# to be http://localhost:3000/oauth/callback

get '/' => sub {
    redirect $auth->authorize;
};

get '/oauth/callback' => sub {
    
    my $access_token  = $auth->get_access_token(param('code'));

    my $authors = LoadFile( 'STACK.yml' );

    my $page;

    for my $auth ( keys %$authors ) {
        next unless $authors->{$auth}{flattr};
        $page .= sprintf "<div>%s - %s</div>\n",
            $auth, flattr( $access_token, $auth, $authors->{$auth}{flattr} );
    }


    return $page;
};

sub flattr {
    my( $access_token, $auth, $flattr ) = @_;

    my $resp = $access_token->post(
        "http://flattr.com/submit/auto?url=https%3A%2F%2Fmetacpan.org%2Fauthor%2F$auth&user_id=$flattr"
    );

    my( $thing ) = (split '/', $resp->header('location'))[-1];

    $resp = $access_token->post(
        "https://api.flattr.com/rest/v2/things/$thing/flattr"
    );

    my %codes = (
        403 => 'flattr_once or owner',
        401 => 'flat broke',
        404 => 'Wut?',
        400 => 'you broke it',
    );

    return $codes{ $resp->code } || $resp->code;
}

dance;
```

That's as ugly as they come, but it'll do the deed. Run the web app, visit
'http://localhost:3000', authenticate your app and watch as the flattrs start
to fly.

## What's Next?

As mentioned, I picked Flattr because it was the easiest service to tap
into for this proof of concept. Any suggestions for another,  more
advantageous micropayment system?

Working for a company that uses Perl for their bread and butter? How about
convincing them to set a small montly flattring amount for the authors in their
stack? Whatever module management you are using at your $workplace, the
scripts showed in this entry should be easy enough to convert.
As usual, the code is available on
[GitHub](https://github.com/yanick/flattr_cpan_stack) --
fork it and go wild.

And if there is an interest, I could always turn Step 3 into a bona fida
web application where peeps could upload their stacks. 


