type=pal
rm t.xml
page=0
for x in 200*
do cd $x
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


cat Dvd-basic.xml t.xml > Dvd.xml
rm t.xml
echo "</dvdauthor>" >> Dvd.xml
