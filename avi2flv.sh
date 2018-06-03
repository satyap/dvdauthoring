mencoder $1  \
    -noidx \
    -o $1.flv  \
    -of lavf  \
    -oac mp3lame \
    -lameopts abr:br=56 \
    -srate 22050 \
    -ovc lavc  \
    -lavcopts vcodec=flv:keyint=50:vbitrate=300:mbd=2:mv0:trell:v4mv:cbp:last_pred=3 \
    -vf scale=800:600  \
    #-vf scale=480:320  \
    #-lavfopts i_certify_that_my_video_stream_does_not_use_b_frames
echo big size

    #-ofps 30 \
