avconv -i $1  -target ntsc-dvd $2
#mencoder -oac lavc -ovc lavc -of mpeg -mpegopts format=dvd:tsaf \
#    -vf scale=720:480,harddup -srate 48000 -af lavcresample=48000 \
#    -lavcopts vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=18:vstrict=0:acodec=ac3:abitrate=192:aspect=16/9 \
#    -ofps 30000/1001 \
#    -o $2 $1
