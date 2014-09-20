type=ntsc
xmlfile=Dvd.xml

page=0
mkdir -p menus/_playall
rm -f menus/_playall/desc.txt $xmlfile

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
      sed "s/^/$x\//;" < desc.txt >> ../menus/_playall/desc.txt
      cat dvdpage* >> ../$xmlfile
      rm dvdpage*
      #for r in *.dv;do tovid mpg -in $r -out $r -$type -dvd -noask;done
    )
done

(
  cd menus/_playall
  perl ~/dvdauthoring/vid2dvd.pl -t $type -p 1 -m menus/_playall -a 1 > t.sh
  sh t.sh
  rm t.sh
  cat dvdpage* >> ../../$xmlfile
  rm dvdpage*
)

echo "</dvdauthor>" >> $xmlfile
dvdauthor -x $xmlfile
genisoimage -dvd-video -o ${type}dvd.iso dvdfs

echo
echo Commands to run next: 
echo wodim -v speed=1 ${type}dvd.iso
echo

