mencoder $1  \
-ofps 25 \
-o $1.flv  \
-of lavf  \
-oac mp3lame \
-lameopts abr:br=64 \
-srate 22050 \
-ovc lavc  \
-lavcopts vcodec=flv:keyint=50:vbitrate=600:mbd=2:mv0:trell:v4mv:cbp:last_pred=3 \
-vf scale=480:320  \
#-vf scale=720:480  \
#-lavfopts i_certify_that_my_video_stream_does_not_use_b_frames
#-lavcopts vcodec=flv:keyint=250:vbitrate=600:mbd=2:mv0:trell:v4mv:cbp:last_pred=3 \
#-ofps 25 \

#-speed $3 \
#-speed 1.05 \
#-vf-add rotate=$2 \
