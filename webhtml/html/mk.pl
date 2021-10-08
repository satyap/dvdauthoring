use strict;
use warnings;
use Data::Dumper;
# 20080720: Now uses Longtail's Flash player


sub stdheader($) {
    my $m = shift;
    <<TXT
    <html>
    <head>
    <title>Videos $m</title>
    <link rel="stylesheet" type="text/css" href="css/style.css" />
    <script type="text/javascript" src="js/prototype.js"></script>
    <script type="text/javascript" src="js/effects.js"></script>
    <script type="text/javascript" src="js/blinds.js"></script>
    </head>
    <body>
    <p><a href="../index.html">Return</a></p>
TXT
}

sub stdfooter() {
    <<TXT
    <p><a href="../index.html">Return</a></p>
    <script type="text/javascript">
    initblinds();
    </script>
    </body>
    </html>
TXT
}

sub flash($) {
    my $file=shift;
    <<TXT;
        <embed src="../media/player.swf"
          width="480" height="340" bgcolor="#ffffff"
          allowscriptaccess="always" allowfullscreen="true"
          flashvars="file=../media/$file" />
TXT
}

sub mp4video($$) {
    my $file=shift;
    my $flash=shift || '';
    <<TXT;
  <video width="720" height="480" controls>
  <source src="$file" type="video/mp4">
  $flash
  </video>
TXT
}
$/=undef;
open(I,"<d.txt");
my @lines=grep /^.+$/, split("\n",<I>);
close(I);

my %titles;
my $title='';

foreach my $line (@lines) {
    if ($line=~/\.dv$/ || $line=~/\.mov$/ || $line=~/\.(avi|mp4)$/) {
        push(@{ $titles{$title} }, $line);
    } else {
        $title=$line;
        $title=~s/\.// if $title=~/^\d{4}\./;
        warn "collision: $title" if exists $titles{$title};
    }
}

my %output;
my $i=0;

foreach my $key (sort keys %titles) {
    my $month=substr($key,0,6);
    #print $month."\n";
    $output{$month}.=<<TXT;
<div class="vidgroup" id="$i">$key</div><div id="video$i" class="video">
TXT
    foreach my $file (@{ $titles{$key} }) {
        if(-f "../media/$file" && $file =~/.mp4$/) {
            $output{$month} .= mp4video("../media/$file", '')
        } elsif(-f "../media/$file.mp4") {
            my $flash = flash("$file.mp4");
            $output{$month} .= mp4video("../media/$file.mp4", $flash)
        } else {
            $output{$month} .= flash("$file.flv")
        }
#        $output{$month}.=<<TXT;
#<object type="application/x-shockwave-flash" 
#width="480" height="340" wmode="transparent" 
#data="../media/flvplayer.swf?file=$file.flv&autostart=false">
#<param name="movie" value="../media/flvplayer.swf?file=$file.flv&autostart=false" />
#<param name="wmode" value="transparent" />
#</object><br/>
#TXT
    }
    $output{$month}.='</div>';
    $i++;
}

foreach my $month (keys %output) {
    open(O, ">$month.html");
    print O stdheader($month);
    print O $output{$month};
    print O stdfooter();
    close(O);
}

