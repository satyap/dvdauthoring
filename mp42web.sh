# Reduce an mp4 for web display
ffmpeg -i "${1}" -crf 25 -s 720x480 "${1}.mp4"
