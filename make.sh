# Entry point; I run this from the dir containing the subdirs containing the
# vids and the desc.txt file.
type=pal
xmlfile=Dvd.xml

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
      perl ~/dvdauthoring/vid2dvd.pl -t $type -l $x/ -p $page -m ../menus/$x -f 1 > t.sh
      sh t.sh
      rm t.sh
      cat dvdpage* >> ../$xmlfile
      rm dvdpage*
      #for r in *.dv;do tovid mpg -in $r -out $r -$type -dvd -noask;done

      # Run this the first time around
      for r in *.dv;do sh ~/dv2${type}.sh $r $r.mpg ;done
    )
done

echo "</dvdauthor>" >> $xmlfile
dvdauthor -x $xmlfile
genisoimage -dvd-video -o ${type}dvd.iso dvdfs

echo
echo Commands to run next: 
echo wodim -v speed=1 ${type}dvd.iso
echo

