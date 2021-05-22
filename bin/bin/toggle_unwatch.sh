#!/bin/sh

name=$(basename $0) 

if [ $# -eq 0 ] 
then
	echo "Usage $name: filename.nfo"

	exit 1
fi

if [ "$name" == "toggle_watch.sh" ] 
then

	sed -i -- 's/<watched>false<\/watched>/<watched>true<\/watched>/g' "$1"
	sed -i -- 's/<playcount>0<\/playcount>/<playcount>1<\/playcount>/g' "$1"

else

	sed -i -- 's/<watched>true<\/watched>/<watched>false<\/watched>/g' "$1"
	sed -i -- 's/<playcount>.<\/playcount>/<playcount>0<\/playcount>/g' "$1"

fi


