#http://stackoverflow.com/questions/21184014/ffmpeg-converted-mp4-file-does-not-play-in-firefox-and-chrome
ffmpeg -i ${1} -b:a 128k -b:v 400k -s 720x480 -pix_fmt yuv420p -movflags +faststart ${1}.mp4

#ffmpeg -y -i $1 -c:v libx264 -preset medium -b:v 555k -pass 1 -c:a libfaac -b:a 128k -f mp4 /dev/null && \
#ffmpeg    -i $1 -c:v libx264 -preset medium -b:v 555k -pass 2 -c:a libfaac -b:a 128k ${1}.mp4


#mencoder -vf pullup,softskip,pp=fd,scale=480:-10,hqdn3d,harddup \
#    -lavdopts threads=2 \
#    -ovc x264 \
#    -x264encopts bitrate=1200:subq=1:frameref=1:qcomp=0.8:8x8dct:weight_b:nob_adapt:me=umh:partitions=p8x8,i4x4:nodct_decimate:trellis=1:direct_pred=auto:level_idc=30:nocabac:threads=auto:keyint=300:pass=1 \
#    -oac faac \
#    -faacopts br=128:raw:mpeg=4:tns:object=2 \
#    -of lavf \
#    -lavfopts format=mp4 \
#    -sws 9 \
#    -ofps 24000/1001 \
#    -srate 22050 \
#    -alang en \
#    $1 \
#    -o /dev/null
#
#mencoder -vf pullup,softskip,pp=fd,scale=480:-10,hqdn3d,harddup \
#    -lavdopts threads=2 \
#    -ovc x264 \
#    -x264encopts bitrate=1200:subq=6:frameref=4:qcomp=0.8:8x8dct:weight_b:nob_adapt:me=umh:partitions=p8x8,i4x4:nodct_decimate:trellis=1:direct_pred=auto:level_idc=30:nocabac:threads=auto:keyint=30:pass=2 \
#    -oac faac \
#    -faacopts br=128:raw:mpeg=4:tns:object=2 \
#    -of lavf \
#    -lavfopts format=mp4 \
#    -sws 9 \
#    -ofps 24000/1001 \
#    -srate 22050 \
#    -alang en \
#    $1 \
#    -o $1.mp4
