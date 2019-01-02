#!/usr/bin/env bash

echo; 

basedir=`dirname $0`
ffmpeg=$basedir/ffmpeg
ffprobe=$basedir/ffprobe

framerate=30
globbing='*.png'

# get input
indir=""
outfile=""


if [ "$1" == "" ]; then
	echo Usage: drop a folder on this app to
	echo transform all images in that folder to a video
	echo
	exit 1;
fi

for indir in "$@"; do

	echo '--------------';
	
	echo 'Input dir: ' $indir
	
	if [ ! -d "$indir" ]; then
		echo Error: $indir is not a dir
		exit 1;
	fi
	
	
	outfile=`dirname $indir`/`basename $indir`.mp4
	read -ep "Output file [$outfile]: " other
	if [ "$other" != "" ]; then
		outfile=$other
	fi
	if [ ! -d "`dirname $outfile`" ]; then
		echo Error: `dirname $outfile` is not a dir
		exit 1;
	fi

	
	read -ep "Globbing [$globbing]: " other
	if [ "$other" != "" ]; then
		globbing=$other
	fi
	
	read -ep "Framerate [$framerate]: " other
	if [ "$other" != "" ]; then
		framerate=$other
	fi
	
	$ffmpeg -framerate $framerate -pattern_type glob -i "$indir/$globbing" \
		-c:v libx264 -pix_fmt yuv420p -qscale:v 2 \
		-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" $outfile
	

	echo "Done. See $outfile"
	
done
