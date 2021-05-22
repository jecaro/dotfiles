#!/bin/sh

SRCDIR=$1
DSTDIR=$2

for SRCFILE in $SRCDIR/*; do

	echo Processing $SRCFILE

	MP3FILE="${SRCFILE%.*}.mp3"
	DSTFILE=$DSTDIR/$(basename $MP3FILE)

	ffmpeg -i "$SRCFILE" -qscale:a 2 "$DSTFILE"

done
