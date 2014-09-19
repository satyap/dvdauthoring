#!/usr/bin/perl
use strict;
use warnings;
use lib '/home/satyap/dvdauthoring';
require 'menubuttons.pl';
# Menu generation script based on
#http://vdrsync.vdr-portal.de/dvdmenus/index.html
# Generates the highlight and select masks. See vid2dvd.pl and menumakefile for examples.

sub syntax() {
    return<<EOT;
    Usage: $0 outputfile.png height fgcolor commands [bgcolor]
    height is 576 for pal, 480 for ntsc
    fgcolor is the foreground (text) color, in rgb triplets e.g. 255,0,0 would be red
    bgcolor is just like fgcolor. bgcolor defaults to fgcolor. If bgcolor =
        fgcolor, then background is transparent.
    commands are like:
        text 9,10 This will appear in the image at 9,10
    Each of those separated by newline. This is somewhat compatible with
    ImageMagick syntax.
EOT
}

if($#ARGV>0) {
    create_image(@ARGV);
}

1;
