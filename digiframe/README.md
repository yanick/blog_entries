---
created: 2015-06-19
tags:
    - perl
    - digikam
---

# From Digikam to a Digital Frame

This one is a random act of duct taping.

So, $spouse happens to have a digital frame dating of a few years. It's not
wireless, so updating its pictures either a question of popping out the sd
card (it doesn't even support usb thumbdrives, so you have the fiddle with the
widdle wee cards), or plug it to the desktop via a usb cable and manually drag
the desired pictures to the mounted SD card.

Surely there's a way to grease up that squeaky process..

The biggest drag of the whole thing is the selection and move of the pictures.
Mostly considering that nowadays most pictures go by the names like
"IMG12345.JPG", and are thrown in massive directories with thousands of their
brethen. Hunting for pics in that context is just no fun. 

Mostly considering that we are using [Digikam](https://www.digikam.org/).
Digikam allows, amongst other things, to tag pictures. Even better, it stores
its information in a convenient SQLite database. 

The schema is nothing very complex, so with the help of 
[DBIx::Class::Schema::Loader](cpan), it's
pretty easy to grab all pictures that, say, have been given the tag
*digiframe*:

```perl
use DBIx::Class;

package MySchema {
    use base qw/DBIx::Class::Schema::Loader/;

    __PACKAGE__->loader_options( naming => 'current', );
}

my $schema = MySchema->connect( 'dbi:SQLite:database='.$digikam_db );

my $tag = $schema->resultset('Tag')->find({name => 'digiframe'})
    or die "tag not found\n";

my @ids = $schema->resultset('ImageTag')->search({
    'tagid' => $tag->id,
})->get_column('imageid')->all;

my @images = $schema->resultset('Image')->search({
    id => \@ids,
})->all;

my %files = map { $_->basename => $_ }  
            map { image_path($schema, $_) } @images;
```

Pretty easy. There's only one thorn in there: Digikam doesn't store the 
path all the way to the root directory, but rather gives you the 
partition where an album is. So to transform that into the full path we have
to be a little clever. Not too much, just a little.

```perl
use Path::Tiny;

sub image_path {
    my( $schema, $img ) = @_;

    my $name = $img->name;

    my $album = $schema->resultset('Album')->find({ id => $img->album })
        or return;

    my $album_path = $album->relativepath;

    my $album_root = $schema->resultset('AlbumRoot')->find({ id => $album->albumroot });

    my $identifier = $album_root->identifier;
    my ( $uuid ) = $identifier =~ /uuid=(.*)/ or die;

    # Digikam stores the partition's UUID, so we have
    # to figure out to which '/dev/*' it relates to.
    # the following work for my Ubuntu system.
    # Caveat emptor and all that

    my $link = readlink "/dev/disk/by-uuid/$uuid" or die;

    ($link) = reverse split '/', $link;

    open my $fh, '-|', 'df -a';
    my %mount;
    while(<$fh>) {
        chomp;
        my @l = split ' ', $_;
        next unless $l[0] =~ s#/dev/##;
        $mount{$l[0]} = $l[-1];
    }

    return path( grep { $_ } $mount{$link}, $album_root->specificpath, $album_path, $name );
}
```

But once this is done, we have our pictures. The SD card I'm using is fairly
small, so I can check if the selection is not too big for it:

```perl
use Format::Human::Bytes;

my %files = map { $_->basename => $_ }  map { image_path($schema, $_) } @images;

my $total_size = sum map { -s $_ } values %files;

say keys(%files) . " pictures selected, total size: ", Format::Human::Bytes::base2($total_size);

die "ooops, we're over our  disk space budget, aborting" 
    if $total_size > $max_size;
```

Now we're ready to copy the files to the card. I can't automate the physical
plugging of the cable, but thanks to `usbmount`, I can make it be auto-mounted
to a `/media/usb*` directory. To recognize which of the usb directories is the
right one, I've created a `digiframe` directory on the card. Now I just have
to make the script watch for any mounted device showing the tell-tale
directory:

```perl
say "We are ready... PLUG IT IN!";

my $media = path('/media');
my $digiframe;

until($digiframe) {
    sleep 1;
    print '.';

    ( $digiframe ) = 
        grep { -d $_ }
        map { $_->child('digiframe') } $media->children( qr/usb\d+/ ); 
}
```


Before we copy the new pictures, we want to remove the old ones that don't
apply anymore:

```perl
my %pictures = map { $_->basename => $_ } grep { -f $_ } $digiframe->children;

my @to_delete = grep { !$files{$_->basename} } values %pictures;

if ( @to_delete ) {
    say "\nFiles to delete: ";
    say "\t", $_ for @to_delete;

    say "looks right?";

    <> =~ /y/ or exit;

    say "deleting $_" and $_->remove for @to_delete;
}
```

That done, we can copy over all the pictures that aren't already there:

```perl
while(my( $name, $f ) = each %files ) {
    print $name, "... ";
    if ( $pictures{$name} ) {
        print "already present\n";
    }
    else {
        $f->copy($digiframe);
        print "copied\n";
    }
}
```

And that's pretty much it. All that is left is to be nice and unmount the usb
connection, and wish the user a good day:

```perl
say "\nunmounting the usb connection";

system 'pumount', $digiframe->parent;

say "Done. Enjoy the pics!";
```
