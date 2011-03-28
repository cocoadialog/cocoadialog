#!/usr/bin/perl -w

use strict;
use IO::File;

our $COCOA_DIALOG = "$ENV{HOME}/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog";
die "$COCOA_DIALOG doesn't exist" unless -e $COCOA_DIALOG;

###
### EXAMPLE 1
###

### Open a pipe to the program
my $fh = IO::File->new("|$COCOA_DIALOG progressbar");
die "no fh" unless defined $fh;
$fh->autoflush(1);

my $percent = 0;
for (my $percent = 0; $percent <= 100; $percent++) {
    if (!($percent % 5)) {
        ### Update the progressbar and its label every 5%
        print $fh "$percent we're at $percent%\n";
    } else {
        ### Update the progressbar every percent
        print $fh "$percent\n";
    }
    ### simulate a long operation
    1 for (0 .. 90_000);
}

### Close the filehandle to send an EOF
$fh->close();

###
### EXAMPLE 2
###

### Now let's do an indeterminate one
$fh = IO::File->new("|$COCOA_DIALOG progressbar --indeterminate");
die "no fh" unless defined $fh;
$fh->autoflush(1);

### Just loop an arbitrary number of times to simulate something taking
### a long time
for (0 .. 1_500_000) {
    ### Update the label every once and a while.
    if (!($_ % 300_000)) {
        my @msgs = ('Still going', 'This might take a while',
            'Please be patient', 'Who knows how long this will take');
        my $msg = @msgs[rand @msgs];
        ### It does not matter what percent you use on an indeterminate
        ### progressbar.  We're using 0
        print $fh "0 $msg\n";
    }
}

### Close the filehandle to send an EOF
$fh->close();

###
### EXAMPLE 3
###

### Here's a move practical example of using an indeterminate progressbar
my $args = '--title "Working..." --text "This will take a while"';
$fh = IO::File->new("|$COCOA_DIALOG progressbar --indeterminate $args");
die "no fh" unless defined $fh;
$fh->autoflush(1);

# Do your really long operation here.
sleep 8;

$fh->close();
