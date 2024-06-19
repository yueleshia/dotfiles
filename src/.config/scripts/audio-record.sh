#/bin/sh
arecord -l
read -r device
ffmpeg -f alsa -i hw:"${device}" -t 30 out.aac
