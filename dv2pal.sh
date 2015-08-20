avconv -i $1  -target pal-dvd $2
#mencoder \
#    -fps 29.97 \
#    -oac lavc -ovc lavc -of mpeg -mpegopts format=dvd:tsaf \
#    -vf scale=720:576,harddup -srate 48000 -af lavcresample=48000 \
#    -lavcopts vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=15:vstrict=0:acodec=ac3:abitrate=192:aspect=16/9 \
#    -ofps 25 \
#    -o $2 test$$.avi
