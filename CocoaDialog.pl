#!/usr/bin/perl
# Wrapper Script for cocoaDialog
# Put somewhere in your path!

use strict;
use warnings;

my $path = "~/Applications"; # Change this to wherever you put cocoaDialog
my $cd = "$path/cocoaDialog.app/Contents/MacOS/cocoaDialog";

system($cd, @ARGV);
