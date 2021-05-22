#!/bin/sh

find $1 -name "*.nfo" -print0 | xargs -0 sed -i -- 's/<watched>false<\/watched>/<watched>true<\/watched>/g'
find $1 -name "*.nfo" -print0 | xargs -0 sed -i -- 's/<playcount>0<\/playcount>/<playcount>1<\/playcount>/g'
