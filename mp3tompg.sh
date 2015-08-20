echo Contains many common commands. View the file.
exit;

# convert mp3 to CD Audio, sampling rate 44100Hz, 2 channels, force wav.
avconv -i input.mp3 -acodec pcm_s16le -ar 44100 -ac 2 -f wav out.wav


base=`echo $1|sed "s/.mp3//;"`
type=$2

len=`mplayer  -identify ${base}.mp3|grep ID_LENGTH|cut -f2 -d'='|cut -f1 -d'.'`
len=`expr $len + 1`
echo "$base = $len seconds"
echo "Making video"

if [ $type == 'ntsc' ]
then true
    nframes=`expr $len \* 30000 / 1001`
    echo $nframes NTSC frames
    ppmtoy4m -S 420mpeg2 -A 10:11 -F 30000:1001 -n $nframes -r \
    ${base}.ppm 2>> ${base}.log | \
    mpeg2enc -a 2 -f 8 -F 4 -n n -b 500 \
    -o ${base}.m2v >> ${base}.log 2>&1
fi
if [ $type == 'pal' ]
then true
    nframes=`expr $len \* 25`
    echo $nframes PAL frames
    ppmtoy4m -S 420mpeg2 -A 59:54 -F 25:1 -n $nframes -r \
    ${base}.ppm 2>> ${base}.log | \
    mpeg2enc -a 2 -f 8 -F 3 -n p -b 500 \
    -o ${base}.m2v >> ${base}.log 2>&1
fi

echo "Converting audio"

#mplayer -quiet -vc null -vo null -ao pcm:waveheader:file=${base}.wav ${base}.mp3

echo "...to ac3"

avconv -i ${base}.mp3 -ab 112 -ar 48000 -ac 2 -acodec ac3 -y ${base}.ac3

echo "Multiplexing"

mplex -V -f 8 -o ${base}${type}.mpg ${base}.m2v ${base}.ac3
rm ${base}.log
rm ${base}.m2v
rm ${base}.ac3

exit;

# create the audio
exit;
mplayer  -quiet -vc null -vo null -ao pcm:waveheader:file=audiodump.wav ${base}.mp3

avconv -i audiodump.wav -ab 224 -ar 48000 -ac 2 -acodec ac3 -y "test.ac3"


r=500
echo =================
echo encoding bitrate $r
echo =================

mkfifo stream.yuv
    
#ntsc
#mplayer -benchmark -nosound -noframedrop -noautosub -vo yuv4mpeg \
#-vf-add scale=720:480  avseq01.mpg &

cat stream.yuv | \
yuvfps -r 30000:1001 -v 0 | \
mpeg2enc --sequence-length 4300 --nonvideo-bitrate 238  --aspect 2 -f 8 \
-b $r \
-g 4 -G 11 -D 10 -K hi-res --frame-rate 4 -v 0 --video-norm n --reduction-4x4 2 --reduction-2x2 1 -q 5 \
-o "testntsc.m2v"

#pal
mplayer -benchmark -nosound -noframedrop -noautosub -vo yuv4mpeg \
-vf-add scale=720:576  avseq01.mpg &

cat stream.yuv | \
mpeg2enc --sequence-length 4300 --nonvideo-bitrate 238  --aspect 2 -f 8 \
-b $r \
-g 4 -G 9 -D 10 -K hi-res --frame-rate 3 -v 0 --video-norm p --reduction-4x4 2 --reduction-2x2 1 -q 5 \
-o "testpal.m2v"

mplex -V -f 8 -O "-500ms" -o ${out}${r}.mpg "testpal.m2v" "test.ac3"
mplex -V -f 8 -O "-500ms" -o ${out}${r}.mpg "testntsc.m2v" "test.ac3"
rm testntsc.m2v
rm testpal.m2v
rm stream.yuv

