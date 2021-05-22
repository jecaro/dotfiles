#!/bin/bash 

# Ignore case
shopt -s nocaseglob

# For all subfolders
find "$1" -type d -print0 | while read -d $'\0' DIR
do

	# Switch into the folder
	echo "cd \"$DIR\"";
	cd "$DIR";

	# Normalize mp3
	if ls -1 *.mp3 >/dev/null 2>&1
	then
		echo "Normalize mp3";
		mp3gain -a -k *.mp3;
	fi
	
	# Normalize aac
	if ls -1 *.m4a >/dev/null 2>&1
	then
		echo "Normalize m4a";
		aacgain -a -k *.m4a;
	fi

	# To do normalize vorbis
	if ls -1 *.ogg >/dev/null 2>&1
	then
		echo "Normalize ogg";
		vorbisgain -a -f *.ogg;
	fi

	# To do normalize flac
	if ls -1 *.flac >/dev/null 2>&1
	then
		echo "Normalize flac";
		metaflac --add-replay-gain *.flac;
	fi

	# Come back
	cd - > /dev/null 2>&1;
done

