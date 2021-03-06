type=ntsc
xmlfile=Dvd.xml
dvdauthoring=~/dvdauthoring

page=0
rm -rf dvdfs
rm $xmlfile

(cd rootmenu && make $type ${type}video clean)

for x in 20*
do 
    page=`expr $page + 1`
    (
      cd $x
      echo $x
      rm -f dvdpage*
      perl $dvdauthoring/vid2dvd.pl -t $type -l $x/ -p $page -m ../menus/$x -f 1 > t.sh
      sh t.sh
      rm t.sh
      cat dvdpage* >> ../$xmlfile
      rm dvdpage*
      for r in *.dv *.avi;do sh $dvdauthoring/dv2${type}.sh $r $r.mpg ;done
    )
done

echo "</dvdauthor>" >> $xmlfile
VIDEO_FORMAT=$type dvdauthor -x $xmlfile -o dvdfs
genisoimage -dvd-video -o ${type}dvd.iso dvdfs

echo
echo Commands to run next: 
echo wodim -v speed=1 ${type}dvd.iso
echo

