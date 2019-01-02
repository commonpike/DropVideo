#!/usr/bin/env bash

echo; 

basedir=`dirname $0`
ffmpeg=$basedir/ffmpeg
ffprobe=$basedir/ffprobe

framerate=30
globbing='*.MOV'

# get input
indir=""
outfile=""


if [ "$1" == "" ]; then
	echo Usage: drop a folder on this app to
	echo join all video files in that folder 
	echo into one mov
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
	
	#read -ep "Framerate [$framerate]: " other
	#if [ "$other" != "" ]; then
	#	framerate=$other
	#fi
	
	#$ffmpeg -framerate $framerate -pattern_type glob -i "$indir/$globbing" \
	#	-c:v libx264 -pix_fmt yuv420p -qscale:v 2 \
	#	-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" $outfile
	#
	
	#ffmpeg -i input1.mp4 -i input2.webm -i input3.mov \
	# -filter_complex "[0:v:0][0:a:0][1:v:0][1:a:0][2:v:0][2:a:0]concat=n=3:v=1:a=1[outv][outa]" \
	# -map "[outv]" -map "[outa]" output.mkv

       
	INPUTS=""
	FILTERS=""
	COUNT=0
	for file in `ls $indir/$globbing`; do
		#echo $file
		INPUTS="$INPUTS -i $file"
		FILTERS=$FILTERS"[$COUNT:v:0][$COUNT:a:0]"
		COUNT=$((COUNT+1))
	done
	FILTERS=$FILTERS"concat=n=$COUNT:v=1:a=1[outv][outa]"

	CMD="$ffmpeg $INPUTS -filter_complex \"$FILTERS\" -map \"[outv]\" -map \"[outa]\" -strict -2 $outfile"
	
	echo
	echo $CMD
	echo
	
	$ffmpeg $INPUTS -filter_complex "$FILTERS" -map "[outv]" -map "[outa]" -strict -2 $outfile
	
	
	#$ffmpeg -safe 0 -f concat -i $indir/join-files.tmp \
	#	-vcodec copy -acodec aac -strict -2 -b:a 384k \
	#	"$outfile"
		
	#$ffmpeg -safe 0 -f concat -i $indir/join-files.tmp \
	#	-vcodec copy -acodec copy \
	#	"$outfile"


	echo "Done. See $outfile"
	
done
