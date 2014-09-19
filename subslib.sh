#:vim set filetype=sh:
mkimg() {
    drawtext="gravity south text 0,30 \"$4\" text 0,55 \"$3\" "
    convert -size $1 +antialias \
    xc:none -font "Helvetica" -pointsize 22 \
    -fill white  \
    -stroke black -strokewidth 3 \
    -draw "$drawtext" \
    -stroke none \
    -draw "$drawtext" \
    -type Palette -colors 3 \
    png8:$2
}
mkpalimg() {
    mkimg 720x576 "$1" "$2" "$3"
}

mkntscimg() {
    mkimg 720x480 "$1" "$2" "$3"
}


