use strict;
use warnings;
use GD;
use GD::Text;

my $fontfile='/usr/share/fonts/truetype/msttcorefonts/Arial.ttf';
my $pointsize=20;

my $red="255,0,0";
my $black="0,0,0";
my $yellow="255,255,0";
my $white="255,255,255";
#my $convert="convert -size 576x384 xc:none";
#my $font="-font Helvetica -pointsize $pointsize";
#my $black="-fill rgb\\(255,255,255\\) -stroke black -strokewidth 4";
#my $yellow="-fill rgb\\(255,255,0\\) -stroke black -strokewidth 4";
#my $red="-fill rgb\\(255,0,0\\) -stroke black -strokewidth 4";
#my $quantcolor="-type Palette -colors 3";

sub calc_yoffset($) {
    my $type=shift;
    my $yoffset=0; # y position displaced by this much for pal and ntsc, = top border, which is half the difference of the heights.
    # 384 is the height of what we consider the safe area. pal height is 576, ntsc height is 480.
    if ($type eq 'pal') { $yoffset=(576-384)/2; }
    elsif ($type eq 'ntsc') { $yoffset=(480-384)/2; }
    return $yoffset;
}

sub menubuttons() {
    # used by vid2dvd
    my $type=shift;
    my $ylocs=shift;
    my $menuloc=shift || '';
    my $num=shift || '';

    my $yoffset=calc_yoffset($type);

    my $buttons='';
    my ($next, $prev, @pair);
    # width is 720 for pal and ntsc, so 
    my $left=20;
    my $right=710;

    my $last = $#$ylocs;
    for(my $i=0;$i<=$#$ylocs;$i++) {
        @pair=@{ $ylocs->[$i] };
        my $name=$i;
        $next=$name+1;
        $prev=$name-1;
        if($prev<0) { $prev=$last; }
        if($next>$last) { $next=0; }
        $buttons.= "<button name=\"t$name\" x0=\"$left\" x1=\"$right\" down=\"t$next\" up=\"t$prev\" ";
        $buttons.= " y0=\"" . ($pair[0]+$yoffset);
        $buttons.= "\" y1=\"" . ($pair[1]+$yoffset) ."\" ";
        $buttons.= "/>\n";
    }

    return <<TXT;
<subpictures>
  <stream>
    <spu force="yes" start="00:00:00.00"
    highlight="$menuloc/hi$num.png"
    select="$menuloc/sel$num.png" >
    $buttons
    </spu>
  </stream>
</subpictures>
TXT

}

# new for 2008
sub calc_menu {
    my ($left, $right, $yoffset, $mlist, $menu, $lines, $buttons, $noffset, $ob, $skip, $cols) = @_;
    # ob = other column's buttons
    my $last = $#$mlist + $noffset;
    my $y=14;
    $y += 30 if($skip==1 && $noffset!=0);

    # calculate the left edge of the menu
    my $left_edge=25; # assume 1st column
    if($noffset!=0) { # not first column
        $left_edge=312; # half-way across the 576-width safe area
    }
    my $l1=$left_edge-24;

    for(my $i=0; $i<=$#$mlist; $i++) {
        $$menu .= "text $left_edge,$y \\\"$mlist->[$i]\\\" \n";
        $$lines .= "text $l1,$y \\\">\\\" \n";
        my $name = $noffset + $i;
        $$buttons .= "<button name=\"t$name\" x0=\"$left\" x1=\"$right\" ";
        if($cols > 1) { # add left/right buttons
            my $t = $i + $#$ob+1; # assume this is first column
            if($noffset!=0) { $t = $i; } #if it's 2nd column, point at 1st column's numbers
            if($skip==1 && $noffset!=0) {$t++} # 2nd column, move down one if there is to be skippage
            if($skip==1 && $noffset==0 && $i==0) {$t++} # 1st column, don't change the pointer as it's based on the offset. only the 1st item (usually "play all") needs adjusting
            $$buttons .= "left=\"t$t\" right=\"t$t\" ";
        }
        my $next=$name+1;
        my $prev=$name-1;
        if($prev<$noffset) { $prev=$last; }
        if($next>$last) { $next=$noffset; }
        $$buttons.= "down=\"t$next\" up=\"t$prev\" ";
        $$buttons.= "y0=\"" . ($y+$yoffset);
        $y +=30;
        $$buttons.= "\" y1=\"" . ($y+$yoffset) ."\" />\n";
    }
    $$buttons .= "\n";
}

sub makemenu() {
    my ($type, $menuitems, $num)=@_;
    my @menu=@$menuitems;
    my $menu="gravity northwest\n";
    my $lines="gravity northwest\n";

    my $skip=0; # if the 2 col menu is uneven, we'll skip 1st row in 2nd column

    my $cols=1;
    $cols=2 if $#menu > 10; # 2 columns if more than 11 items

    my @menu1=@menu;
    my @menu2=();

    if($cols==2) {
        my $items = $#menu + 1;
        my $half=int($items/2);
        if($items % 2 == 1) {
            $skip=1;
            $half++;
        }
        @menu1=splice(@menu, 0, $half);
        @menu2=@menu;
#    print "$half\n";
#    print join("\n",@menu1);
#    print "\n---\n";
#    print join("\n", @menu2);
#    print "\n$skip\n";
#    exit;
    }

    my $y=14; # starting y coordinate

    my $yoffset=calc_yoffset($type);

    my $buttons=''; # the buttons will fill up here

    # width is 720 for pal and ntsc, so 
    # widths are either 20 to 710 or
    # if two columns, 20 to 355 and 360 to 710
    my $left1=20;
    my $right1=355;
    my $left2=360;
    my $right2=710;

    if($cols==1) {
        calc_menu($left1, $right2, $yoffset, \@menu, \$menu, \$lines, \$buttons, 0, [], 0, $cols);
    } elsif ($cols==2) {
        calc_menu($left1, $right1, $yoffset, \@menu1, \$menu, \$lines, \$buttons, 0, \@menu2, $skip, $cols);
        calc_menu($left2, $right2, $yoffset, \@menu2, \$menu, \$lines, \$buttons, $#menu1 + 1, \@menu1, $skip, $cols);
    }

    $buttons=<<EOF;
<subpictures>
  <stream>
    <spu force="yes" start="00:00:00.00"
    highlight="./hi$num.png"
    select="./sel$num.png" >
$buttons
    </spu>
  </stream>
</subpictures>
EOF

    return ($buttons, $menu, $lines);
}

sub make_canvas() {
    my $height=getHeight(shift);
    my $menu=shift;
    my $num=shift || '';
    my $extra_image=shift || '';
    if($extra_image) {
        create_image("tcanvas$num.png", $height, $white, $menu, $black);
        #print `$convert $font $black -draw \"$menu \" -stroke none -draw \"$menu \" tcanvas$num.png`;
        print `composite -compose over -gravity southeast -geometry "+40""+40" $extra_image tcanvas$num.png fgcanvas.png`;
        unlink("tcanvas$num.png");
    } else {
        create_image("fgcanvas$num.png", $height, $white, $menu, $black);
        #print `$convert $font $black -draw \"$menu \" -stroke none -draw \"$menu \" fgcanvas$num.png`;
    }

}

sub make_fg() {
    my $menu=shift;
    my $lines=shift;
    my $height=getHeight(shift);
    my $num=shift || '';
    #print `$convert $font $yellow -draw \"$menu $lines\" -stroke none -draw \"$menu $lines\" $quantcolor  png8:fghi.png`;
    #print `$convert $font $red    -draw \"$menu $lines\" -stroke none -draw \"$menu $lines\" $quantcolor png8:fgsel.png`;
    my $text = $menu ."\n". $lines;
    create_image('hi.png', $height, $yellow, $text);
    create_image('sel.png', $height, $red, $text);
}

# Menu generation script based on
#http://vdrsync.vdr-portal.de/dvdmenus/index.html
# Generates the highlight and select masks. See vid2dvd.pl and menumakefile for examples.

sub create_image(@) {
    #print join("*", @_);
    #print $font;
    my $output=shift || die syntax();
    my $height=shift;
    my $color=shift;
    my $text=shift;
    my $bgcolor=shift || $color;
    $text =~ s/\s*gravity \S+\s*/\n/g;
    my @text = split(/\n/, $text);
    my $ret_img = new GD::Image("720", $height);

    my @rgb = split(',', $color);
    my $fg=$ret_img->colorAllocate(@rgb);

    my @bg_rgb = split(',', $bgcolor);
    #print "$bgcolor*\n";
    my $bg = $ret_img->colorAllocate(@bg_rgb);
    if($bgcolor eq $color) {
        $ret_img->transparent($bg); # This makes it transparent, as well as a 1-bit colormap.
    }
    $ret_img->filledRectangle(0,0, (719), ($height-1), $bg);

    foreach my $line (@text) {
        next if $line=~/^\s*$/;
        chomp($line);
        #print "*$line*i\n";
        $line=~s/^text //m;
        my ($coords, $text) = split(/\s/, $line, 2);
        $text=~s/\\"//g;
        my ($left, $top) = split(',', $coords);
        # The left and top that come out of the scripts are adjusted for a 576x384
        # image (to comensate for borders getting cut off).
        $ret_img->stringFT($fg, $fontfile, $pointsize, 0, $left + (720-576)/2, $top + $pointsize + ($height-384)/2, $text);
    }

    open(O, "> $output");
    binmode(O);
    print O $ret_img->png;
    close(O);

}

sub getHeight($) {
    my $type=shift;
    $type eq 'ntsc' ? '480':'576';
}

sub make_xml() {
    my $menu = shift;
    my $all = $#$menu + 1;
    my $buttons = "";
    my $jumps = "";
    for(my $i=1;$i<=$#$menu; $i++) {
        $buttons .= '<button name="t' . $i . '">jump titleset ' . $i . ' menu;</button>';
        $buttons .= "\n";
        $jumps .= "if(g3 eq " . ($i+1) . ") jump titleset " . $i . " menu;\n";
    }
    my $ret = <<EOT;
<dvdauthor dest="./dvdfs">
  <vmgm>
    <menus>
      <pgc entry="title">
        <pre>{
$jumps
          g3=0;
            }</pre>
        <vob file="./rootmenu/menu.mpg" pause="inf" />
          <button name="t0">jump titleset $all menu;</button>
$buttons
      </pgc>
    </menus>
  </vmgm>
EOT
    return $ret;
}

1;
