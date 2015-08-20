use strict;
use warnings;
#use Image::Magick;
use Data::Dumper;
use Getopt::Std;
use lib '/home/satyap/dvdauthoring';
my $lib = '/home/satyap/dvdauthoring';
require 'menubuttons.pl';

my %opts;
getopt('aistbpfml', \%opts);
my $type=$opts{'t'} || '';
my $bgfile=$opts{'b'} || '';
my $subtitles=$opts{'s'} || 0;
my $pagenumoffset=$opts{'p'} || 0;
my $pathprefix=$opts{'l'} || '';
my $menuloc=$opts{'m'} || 'menu';
my $inputfile=$opts{'i'} || 'desc.txt';
my $playallonly=$opts{'a'} || 0;

my $bestfit=$opts{'f'} || 0;
# 1= will try to reduce extra menu pages by cramming 1 more item into each menu page
# 0= won't, you'll get a gap before the "Back to main menu" option

if($type ne 'pal' && $type ne 'ntsc') { &syntax };

my @lines=grep {/.+/} (`cat $inputfile`);

my $menuitem=-1;
my @set;
#my @files=();
my $setnum=0;
my $numfiles=0;

# list of menu sets (index=setnum)
#   each item=list of menu items (index=menuitem)
#     each item=list of files (index=numfiles) - first element is description

my $maxmenuitem=9;
if($bestfit) {
    $maxmenuitem=10;
}

foreach my $line (@lines) {
    next if $line=~/^#/;
    chomp($line);
    $line=~s/^\s+//;
    $line=~s/\s+$//;
    if($line=~/\.dv$/ || $line=~/^dscn/ || $line=~/\.mpg$/ || $line=~/\.mpg\.out$/) {
        $set[$setnum][$menuitem][$numfiles]=$line;
        $numfiles++;
    }
    else {
        $numfiles=1;
        $menuitem++;
        if(!$playallonly && $menuitem>$maxmenuitem) {
            $setnum++; $menuitem=0;
        }
        $set[$setnum][$menuitem][0]=$line;
    }
}

#print Dumper($set[0]);

my $num=1;
my $menuxml='';
my $subxml='';
my $menu='';
my $dvdxml='';
foreach my $page (@set) {
    my ($text, $lines, $coords) = &calcmenu($page);
    $menuxml.= &printmenuxml($coords, $num);
    foreach my $title (@$page) {
        $subxml.= &printsubxml($title) if $subtitles;
    }
    $menu.= &printmenu($text, $lines, $num, $num+$pagenumoffset);
    $dvdxml.= &printdvdxml($num,$page, $num+$pagenumoffset);
    $num++;
}

print<<EOF;
mkdir -p $menuloc
################# dvd xml:
$dvdxml
################# menu xml:
$menuxml
################# menu images and video:
avconv -ar 48000 -f s16le -i /dev/zero -ac 2 -ar 48000 -ab 224k -t 4 -acodec ac3 -y $menuloc/menu.ac3
$menu
rm $menuloc/menu.ac3
EOF
if ($subtitles){
    print<<EOF;
################# subtitles:
$subxml
EOF
}

exit;

######################

sub syntax() {
    print<<EOF;
Usage: $0 -t (pal|ntsc) [-b bg.jpg] [-p num] [-s 1] [-f 1] [-l "../200701/"] [-m ../menus/200701]
 num  = page number offset.
 -b   = takes a filename for the background image.
 -s 1 = enable subtitles containing menu items
 -f 1 = will try to reduce extra menu pages by cramming 1 more item into each menu page
       Without -f, it won't, you'll get a gap before the "Back to main menu" option
 -l   = will prefix the locations of menu and file paths (in the dvdpage XML files) 
       with the given string. "../200701/" results in "../200701/menu/menu1.mpg" etc.
       Default: ''
 -m   = puts the menu files in the prefixed directory/file: -m ../menus/200701 will
       put the menu files in ../menus/200701 like ../menus/200701/menu.mpg.
       It should be relative to where the videos are (i.e. to the value of -l)
       Default: -m menu (so puts the files in menu/menu.mpg)
 -i   = input file name. Default desc.txt
 -a 1 = Show only the "Play all in this set" menu item. Default: 0
       
EOF
    exit;
}


sub printsubxml() {
    my $ti=shift;
    my $ret;
    
    my ($date,$titler)=split(' ',$ti->[0],2);
    
    for(my $i=1;$i<=$#$ti;$i++) {
        $ret.=mkimg($ti->[$i], $date, $titler);
#mk${type}img $ti->[$i].png $date \"$titler\"
        $ret.= <<TXT;
cat <<EOF > $ti->[$i].xml
<subpictures>
    <stream>
    <spu start="00:00:00,0" image="$ti->[$i].png"
    transparent="ffffff" />
    </stream>
</subpictures>
EOF
TXT
        $ret.=  "spumux $ti->[$i].xml < $ti->[$i].mpg > $ti->[$i].st.mpg\n";
        #$ret.=  "mv t.mpg $ti->[$i].mpg\n";
    }

    return $ret;
} # printsubxml


sub printmenu() {
    my $text=shift;
    my $lines=shift;
    my $num=shift;
    my $pagenum=shift;
    
    my $ret;
    my $convert='convert -size 576x384 xc:none ';
    my $font='-font "Helvetica" -pointsize 22 ';
    my $drawblack='-fill "rgb(255,255,255)" -stroke black -strokewidth 3 ';
    #my $drawyellow='-fill "rgb(255,255,0)" -stroke black -strokewidth 3 ';
    #my $drawred='-fill "rgb(255,0,0)" -stroke black -strokewidth 3 ';
    #my $palette='-type Palette -colors 3 ';
    my $pagenum_text="gravity southeast text ";
    my ($abssize, $size, $ppmtoy4m, $mpeg2enc, $height);
    if($type eq 'pal') {
        $size='720x576';
        $abssize='!720x!576';
        $ppmtoy4m="59:54 -F 25:1 -n 100";
        $mpeg2enc='-F 3 -n p';
        $height='576';
        $pagenum_text .= "" . (720-576) . "," . (576-384);
    }
    if($type eq 'ntsc') {
        $size='720x480';
        $abssize='!720x!480';
        $ppmtoy4m="10:11 -F 30000:1001 -n 119";
        $mpeg2enc='-F 4 -n n';
        $height='480';
        $pagenum_text .= "" . (720-576-16) . "," . (480-384-16);
    }
    $pagenum_text .= " \\\"$pagenum\\\"";

    my $convertbg="convert -size $size gradient:\"rgb(0,0,0)\"-\"rgb(0,0,0)\" $menuloc/bg.png";

    if($bgfile ne '') {
        # If a background is given, use it instead of creating a black image.
        $convertbg="convert -resize '$abssize' $bgfile $menuloc/bg.png";
    }

    my $logfile="$menuloc/makemenu.log";
    my $text_for_overlay=$text;
    $text_for_overlay =~s/\\"//g;

    $ret.= <<EOF;
$convertbg
# superimpose the page number
convert +antialias $font $drawblack -draw "$pagenum_text" \\
    -stroke none -draw "$pagenum_text" \\
    $menuloc/bg.png $menuloc/bg.png

perl $lib/menuMask.pl $menuloc/fgcanvas$num.png $height 255,255,255 "$text"
EOF
#convert -size $size xc:none -matte $menuloc/bgtrans.png
#$convert -antialias $font $drawblack \\
#  -draw "gravity northwest $text $pagenum" \\
#  -stroke none -draw "gravity northwest $text $pagenum" \\
#  $menuloc/fgcanvas$num.png
#$convert +antialias $font $drawyellow \\
#  -draw "gravity northwest $text $lines" \\
#  -stroke none -draw "gravity northwest $text $lines" \\
#  $palette \\
#  png8:$menuloc/fghi$num.png
# 
#$convert +antialias $font $drawred \\
#  -draw "gravity northwest $text $lines" \\
#  -stroke none -draw "gravity northwest $text $lines" \\
#  $palette \\
#  png8:$menuloc/fgsel$num.png
#composite -compose Src -gravity center $menuloc/fghi$num.png $menuloc/bgtrans.png $menuloc/hi$num.png
#composite -compose Src -gravity center $menuloc/fgsel$num.png $menuloc/bgtrans.png $menuloc/sel$num.png

$ret.=<<EOF;
composite -compose Over -gravity center $menuloc/fgcanvas$num.png $menuloc/bg.png -depth 8 $menuloc/menu.ppm
perl $lib/menuMask.pl $menuloc/hi$num.png $height 255,255,0 "$text $lines"
perl $lib/menuMask.pl $menuloc/sel$num.png $height 255,0,0 "$text $lines"

ppmtoy4m -S 420mpeg2 -A $ppmtoy4m -r $menuloc/menu.ppm 2>> $logfile |   mpeg2enc -a 2 -f 8 $mpeg2enc -o $menuloc/menu.m2v >> $logfile 2>&1

mplex -V -f 8 -o $menuloc/menu.temp.mpg $menuloc/menu.m2v $menuloc/menu.ac3 >> $logfile 2>&1
spumux $menuloc/menu$num.xml < $menuloc/menu.temp.mpg > $menuloc/menu$num.mpg

#rm -f $menuloc/fghi$num.png $menuloc/fgsel$num.png $menuloc/bgtrans.png
rm -f $menuloc/bg.png $menuloc/fgcanvas$num.png
rm -f $menuloc/hi$num.png $menuloc/sel$num.png $menuloc/menu.ppm $menuloc/menu$num.xml
rm $logfile $menuloc/menu.m2v $menuloc/menu.temp.mpg 
EOF

return $ret;
} # printmenu

sub calcmenu() {
    my $page=shift;
    my $coords;
    my $text='';
    my $lines='';

    my $ret;

    my $y=0;
    my $lineoff=0;
    $text.="\ntext 15,$y" . ($playallonly ? ' Play all on disc' : ' Play all in this set');
    push(@$coords, [$y,$y+30]);
    $lines.="\ntext 1,$y > ";
    $y+=30;
    foreach my $title (@$page) {
        next if $playallonly;
        my $title=$title->[0];
        $title=~m/^([.0-9]+)\S*?\s/;
        my $d=$1;
        $title=~s/^[.0-9]+\S*?\s//;
        $d=~s/\.//g;
        $d.=' ' if $d;
        $text .= "\ntext 15,$y $d$title ";
        push(@$coords, [$y,$y+30]);
        $lines.="\ntext 1,$y > ";
        $y+=30;
    }
    if ($bestfit) {
        $y+=2;
    } else {
        $y+=14;
    }
    $text.="\ntext 15,$y" . ' Back to menu';
    push(@$coords, [$y,$y+30]);
    $lines.="\ntext 1,$y > ";
    return ($text, $lines, $coords);
} # calcmenu


sub printmenuxml() {
    my $ylocs=shift;
    my $num=shift;
    my $buttonxml=&menubuttons($type, $ylocs, $menuloc, $num); #, 0, 'full', $num);

    my $ret.= <<TXT;
cat <<EOF > $menuloc/menu$num.xml
$buttonxml
EOF
TXT

return $ret;
} # printmenuxml


sub printdvdxml() {
    my $num=shift;
    my $page=shift;
    my $pagenum=shift() - 1;
    my $nextpage=$pagenum+1;
    my $ret='';
    
    my $vids='';
    my $playall='';
    my $pause=' pause="2"';
    
    my $buttons='';
    for(my $i=0;$i<=$#$page;$i++) {
        $buttons.= "    <button name=\"t" . ($i+1) . "\">subtitle=0;jump ";
        $buttons.= "title " . ($i+1) . ";</button>\n";
        my $vid=$page->[$i];
        $vids.="<pgc>\n";
        for(my $j=1;$j<=$#$vid; $j++) {
            my $vob;
            if ($subtitles) {
                $vob="  <vob file=\"${pathprefix}$vid->[$j].st.mpg\"";
            } else {
                $vob="  <vob file=\"${pathprefix}$vid->[$j].mpg\"";
            }
            $vids.= $vob;
            $playall.= $vob;
            if($j==$#$vid) { # if this is the last one
                $vids.= $pause;
                if($i==$#$page) { #last one on page
                    $playall.= $pause;
                }
            }
            $vids.=" />\n";
            $playall.=" />\n";
        }
        $vids.="  <post>call menu;</post>\n</pgc>\n";
    }
    
    my $lastbutton=$#$page + 2;
    my $playalltitle=$#$page + 2;
    if($playallonly) {
        $vids = $buttons = '';
        $playalltitle=1;
        $lastbutton=1;
    }

    $ret.=<<TXT;
    cat <<EOF > dvdpage$num.xml
  <titleset><menus><pgc entry="root">
  <pre>{
  if(g3 eq $nextpage) jump vmgm menu;
  if(g3 eq $pagenum) jump title $playalltitle;
  }</pre>
   <vob file="${pathprefix}$menuloc/menu$num.mpg" pause="inf" />
   $buttons
    <button name="t0">subtitle=0;jump title $playalltitle;</button>
    <button name="t$lastbutton">jump vmgm menu;</button>
    </pgc>
</menus>
<titles>
$vids 
    <pgc>
    <pre>{
if (g3 gt 0) g3=999;
}</pre>
    $playall
    <post>{
if (g3 gt 0) g3=$nextpage;
call menu;
}</post>
    </pgc>
    </titles>
</titleset>
EOF
TXT
# the pre section for playall sets g3 to a larger value than number of
# submenus... so if menu is hit during play-all, it will jump to menu and not
# get stuck going to next page.

return $ret;
} # printdvdxml

sub mkimg() {
    # make image for subtitles
    my $imgname=shift;
    my $date=shift;
    my $titler=shift;
    my $size;
    $size='720x576' if $type eq 'pal';
    $size='720x480' if $type eq 'ntsc';
    $date=~s/_/ /;
    $date=~s/-/:/;
    $date=~s/-\d\d$//;
    my $drawtext="gravity south text 0,30 \\\"$titler\\\" 
    text 0,55 \\\"$date\\\" ";
    return <<TXT;
convert -size $size +antialias \\
  xc:none -font "Helvetica" -pointsize 22 \\
  -fill white  \ -stroke black -strokewidth 3 \\
  -draw "$drawtext" \\
  -stroke none \\
  -draw "$drawtext" \\
  -type Palette -colors 3 \\
  $imgname.png
TXT

} # mkimg
