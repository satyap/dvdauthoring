type=pal
xmlfile=Dvd.xml
xml_basicfile=Dvd-basic.xml

rm t.xml
page=0
for x in 20*
do cd $x
    echo $x
    page=`expr $page + 1`
    rm -f dvdpage*
    perl ~/dvdauthoring/vid2dvd.pl -t $type -l $x/ -p $page -m ../menus/$x > t.sh
    sh t.sh
    rm t.sh
    cat dvdpage* >> ../t.xml
    rm dvdpage*
    for r in *.dv;do tovid mpg -in $r -out $r -$type -dvd -noask;done
    cd ..
done


cat $xml_basicfile t.xml > $xmlfile
rm t.xml
echo "</dvdauthor>" >> $xmlfile
(cd rootmenu && make ${type} ${type}video)

dvdauthor -x $xmlfile
genisoimage -dvd-video -o ${type}dvd.iso dvdfs

echo
echo Commands to run next: 
echo wodim -v speed=1 ${type}dvd.iso
echo

