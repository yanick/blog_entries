---
title: I Can't Pass You the Butter, and Here Is Why...
url: pass-the-butter
format: markdown
created: 2012-02-26
tags:
    - Perl
    - exception handling
---

I have a *Person* class, and I want to know if they can
pass the butter.  So far, it's hardly a problem,

    #syntax: perl
    $self->take('bread roll') and $self->grab('knife') 
        if $georges->can_pass_the_butter;

But here's the rub. If *$georges* can't pass the butter, I want 
to know why. Is it because he's too far away, because there is 
no butter on the table, because he doesn't like me, or any 
other reason?  What is the most elegant way of knowing the *if* and the *why*?

## Way no.1: Play 20 Questions

An obvious way of doing it would be to have two methods for the two types of
questions:

    #syntax: perl
    unless( $georges->can_pass_the_butter ) {
        say 'Sorry, that is not possible because ',
            $georges->explains_why_he_cant_pass_the_butter;
    }

Urgh. That's cumbersome. And likely to duplicate effort needlessly in the
logic of the two methods. So, no, it won't do.

## Way no.2: Yes, we have no banana

Maybe we could return something that is both the reason and the boolean
answer.  So, maybe we could flip the question around?

    #syntax: perl
    sub cant_pass_the_butter {
        # some stuff...

        return "there's only margarine" 
            unless $table->has('butter');

        # more checks...

        # okay, we don't have a single good reason 
        # not to pass the butter

        return;
    }

    # and later on

    if ( my $reason = $georges->cant_pass_the_butter ) {
        ...
    }

Yeah... Technically speaking, it works. But this paves the way to double
negations and convoluted 'if/unless' statements. I think it's safe to say
that it's not something we wouldn't generally do not want. Or not. I lost
count.

## Way no.3: Executive summary versus full report

Something else we could use is Perl's functions ability to know if they are
called in a scalar or list context. We could return the boolean alone in a
scalar context, and the boolean and the reason in a list context, like thus

    #syntax: perl
    sub can_pass_the_butter {
        # some stuff...

        if ( $self->cordiality( $requester ) < 0 ) {
            return wantarray ? ( 0, "get it yourself" ) : 0;
        }

        # more checks...

        # okay, we don't have a single good reason 
        # not to pass the butter

        return 1;
    }

    # and later on

    # just wanna know
    $self->grab('bread roll') if $georges->can_pass_the_butter;

    # wanna know why
    my ( $answer, $reason ) = $georges->can_pass_the_butter;
    die "Dinner ruined: $reason" unless $answer;


Again, not ideal. The list invocation of the condition is a wee bit
cumbersome, and we always have to remember that it yield two different things
in a scalar and list context, so that we don't have surprises when we do
things like

    #syntax: perl
    $self->init_meal( 
        salt => $sylvia->can_pass_salt, 
        butter => $georges->can_pass_the_butter
    );


Ooops. That will fail. What we needed to do was

    #syntax: perl
    $self->init_meal( 
        salt => $sylvia->can_pass_salt, 
        butter => scalar $georges->can_pass_the_butter
    );


So... yeah, surely we can still do better than that.

## Way no.4: Everything's better with dark magic

Instead of returning a list, what if we could return a value that is a boolean 
*and* the reason. A variable that has a certain, what is the word, duality to
it?

    #syntax: perl
    use Contextual::Return;

    sub can_pass_the_butter {
        # some stuff...

        return  BOOL { 0 } 
                SCALAR { '... I would rather not' } 
            if $self->seen('Last Tango in Paris');

        # more checks...

        # okay, we don't have a single good reason 
        # not to pass the butter

        return BOOL { 1 };
    }

    # and later on

    unless ( my $answer = $georges->can_pass_the_butter ) {
        warn "butter not available: $answer";
    }

Ah AH! Fooled you, did I? I'm sure you thought I was going to do

    #syntax: perl
    use Scalar::Util qw/ dualvar /;

    sub can_pass_the_butter {
        # some stuff...

        return dualvar 0, "you'll get your butter when you pry it from my dead, cold udders" 
            if $self->isa('bovine');

        # more checks...

        # okay, we don't have a single good reason 
        # not to pass the butter

        return dualvar 1, '';
    }

Well, truth is, so did I. But then I tried it and discovered that the string 
has precedence over the numerical value for boolean comparisons, so we would
need to do

    #syntax: perl
    my $verdict = $georges->can_pass_the_butter;
    warn "Your bread roll is going to be dry: $verdict" 
        unless 0 + $verdict;

which is **not** appealing.  The [Contextual::Return](cpan) way is much
more palatable, although a little bit on the dark magic side.

## Way no.5: Say it with a suicide note

Now, something I noticed is that a lot of the use cases above looks like
the typical '`... or die`' construct. So maybe we could piggy-back on our
exception mechanism?

    #syntax: perl

    sub can_pass_the_butter {
        # some stuff...

        die "this is a cruel jape, my lord"
            if $self->upper_limbs == 0;

        # okay, we don't have a single good reason 
        # not to pass the butter

        return 1;
    }

    # and later on

    if ( eval { $georges->can_pass_the_butter } ) {
        # num num
    }
    else {
        warn "can't get butter: $@";
    }
 

That method minimizes the gymnastics one has to do in `can_pass_the_butter()`
and is pretty easy to use. Excepts, of course, that if somebody doesn't
read the documentation and doesn't wrap the check in an `eval{}`, he's going
to get the surprise of his life when he'll get stabbed in the face for what
should have been a totally innocent question. Not very good table manners,
that.

## Way no.6: no.5 redux, minus the face-stabbing part

The previous solution was almost viable. Now, what if we try to go that way,
while making the negative answer a little less explosive?

    #syntax: perl

    sub can_pass_the_butter {
        # some stuff...

        if ( $self->is( 'Pillsbury doughboy' ) ) {
            $@ = "Ooooh no. I know what you're thinking, buster...";
            return 0;
        }

        # okay, we don't have a single good reason 
        # not to pass the butter

        return 1;
    }

    # and later on

    unless ( $georges->can_pass_the_butter ) {
        if ( $bread_roll->look( 'delicious' ) ) {
            die;
        }
        else {
            say "Oh well, can't have rolls because: $@";
        }
    }

Now, this is beginning to be more like it. The condition can be written 
in a succinct and intelligible manner. The reason can be retrieved whenever we
want. And we get the bonus that if we use a naked `die`, the already
defined *$@* is going to be propagated.  All of that for a
not-so-terribly-evil use of *$@*. 

So far, that's my favorite solution. It's fairly intuitive and unobstrusive.
It's not totally foolproof, mind you, but the scenarios where it could play
havoc with the developer's mind are sufficiently remote from the golden path
that I don't think I have to overwhelmingly worry about them.

## There has to be more than 6 ways to do it

But enough about me. What about you? What's your usual way of dealing with that specific problem?



