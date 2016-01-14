#!/bin/sh

echo -n "\033]0; Converting $1\007"
/usr/bin/avconv -y -i "$1" -target ntsc-dv -aspect 4:3 -f dv "$1.dv"

