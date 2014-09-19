use strict;
use warnings;
use lib '/home/satyap/dvdauthoring';
require 'menubuttons.pl';

my @menu=(
    "1. Play All" ,
    "2. Jan 2009 1" ,
    "3. Jan 2009 2" ,
    "4. Feb-Jun 2009" ,
    "5. Jul 2009 1" ,
    "6. Jul 2009 2" ,
    "7. Aug 2009" ,
    "8. Sep-Oct 2009" ,
    "9. Nov 2009" ,
);

my $type=$ARGV[0] || die "ntsc or pal required";
my $num=$ARGV[1] || '';

my($buttons, $menu, $lines) = makemenu($type, \@menu, $num);

open(MENU, ">menu.xml") || die "menu.xml: $!";
print MENU $buttons;
close(MENU);

make_canvas($type, $menu, $num, "nirmate.png");

make_fg($menu, $lines, $type, $num);

exit;
