type=ntsc
xmlfile=Dvd.xml

page=0
rm -rf dvdfs
rm $xmlfile

(cd rootmenu && make $type ${type}video clean)

for x in 20*
do (
      cd $x
      echo $x
      page=`expr $page + 1`
      rm -f dvdpage*
      perl ~/dvdauthoring/vid2dvd.pl -t $type -l $x/ -p $page -m ../menus/$x > t.sh
      sh t.sh
      rm t.sh
      cat dvdpage* >> ../$xmlfile
      rm dvdpage*
      for r in *.dv;do tovid mpg -in $r -out $r -$type -dvd -noask;done
    )
done

echo "</dvdauthor>" >> $xmlfile
dvdauthor -x $xmlfile
genisoimage -dvd-video -o ${type}dvd.iso dvdfs

echo
echo Commands to run next: 
echo wodim -v speed=1 ${type}dvd.iso
echo

