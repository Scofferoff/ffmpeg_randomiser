#!/bin/bash

# http://ffmpeg.org/documentation.html

# Run ffmpeg in various ways to obfusticate the original content 
# In theory this may slow down automatic algorithmic identification from social media platforms for censorship.
# Only uses CPU conversion, no GPU support yet

# Best run with the -s option 

# Use only with landscape videos for now

# "copy" array values mean keep Output settings as Input, No change, some items don't accept Copy

# Good output video extensions are .mp4, .mkv & .webm, Anything that supports the list of a_codec and v_codec options
# ffmpeg should read almost any video input

#Generate 5 different videos#
 # $ for i in {1..5}; do ./ffmpeg_randomiser.sh input_video.mp4 output_$i.mp4 -s; done

# Add or remove options to any of the arrays. be careful not to include options that aren't suitable for some encoders/wrappers
# AUDIO
a_bitrate_b_a=("96k" "128k" "192k" "256k" "320k") # bits/s
a_codec=("copy" "flac" "aac" "ac3" "vorbis" "libvorbis")
a_channels_ac=("1" "2") # Add more if you really want 2.1+ This is intended for Social media shares
a_hertz_ar=("16000" "44100" "48000" "96000")

# VIDEO
v_bitrate_b_v=("copy" "350k" "700k" "1200k" "2500k" "5000k")
v_codec=("copy" "libx264" "libx264rgb" "libx265" "libxvid" "h264_v4l2m2m") # ffmpeg -encoders
v_resize_s=("hd720" "hd1080" "wxga" "wvga" "wsxga" "wuxga") # predefined video resolutions, might not work with Portrait videos?
# ^ problematic if upscaling, but only in terms of visual quality/bluring
v_framerate_r=("ntsc" "pal" "film" "ntsc-film") # convert framerates
v_wrapper=("mp4" "mkv") # Anything that suits the encoders, but defined in out_file

# FILTERS
f_filter_string=() # Array to hold optional filters
f_recolor_curves=("curves=b='0/0 0.99/0.95'" "curves=r=0/0.1 0.99/1:b=0/0.1 0.99/1") # change colour values
f_flipH_hflip=0
f_sharpen_unsharp=0 # This isn't useful but will change pixels per frame, therefore the overall content.
# Zooming is a 2 step filter of scaling and cropping
f_scale_crop=("scale=1.01*iw:-1,crop=iw/1.01:ih/1.01" "scale=0.99*iw:-1,crop=iw/0.99:ih/0.99") # Can simplify this by just selecting a number and inserting to final string.

# GENERAL SETTINGS
fixed_size_fs="0" # 0 or 1: Generate a file of fixed size, NOT IDEAL FOR THIS SITUATION

RANDOM=$$$(date +%s)

v_dont_resize=0
overwrite=0

usage="Usage: ./ffmpeg_randomiser.sh input_filename new_filename.mp4 [-options]
        # [options] are optional
        # new_filename can have extensions MP4 or MKV, this determines the final format
        # Unless you want to copy the input_file format, then new_filename should have the identical extension.
        # Existing new filenames will create a prompt to overwrite.
        # new_filename can be e.g dir1/dir2/new_filename, as long as those directories exist

        [OPTIONS] space seperated list: e.g -r -m -y
        -c = crop the image slightly, changes edge pixels.
        -m = mirror, flips the video horizontally
        -r = recolor randomly, minimal color balance changes
        -u = runs a Sharpen filter on each frame, may not change anything visually, but changes each frame, SLOW
        -s = Don't randomly resize the video. The potential upscaling reduces quality.
        -y = Overwrite existing files without prompting.
        "

case "$1" in
    "-h"|"--help"|"/?"|"?")
        printf "$usage"
        exit 0
        ;;
esac

# Verify file is readable and then get the dimensions of it.
if [ ! -f "$1" ]; then
    printf "ERROR: File not found\n $usage"
    exit 1
else # file exists, so get some information from it
    #? This should come after checking for -s switch?
    IFS="," read -a vid_dims <<< $(ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=width,height -print_format csv "$1")
    if [[ ${#vid_dims[@]} != 3 || $vid_dims[1] < 1 ]]; then 
        echo "\nCould not get video dimensions from Input file! exiting.\n"
        exit 1
    fi
fi

infile="$1"
#infile_ext="${outfile##*.}"

outfile="$2"
#outfile_ext="${outfile##*.}"

# Some optional options are optional
# Adds filter options to an array
for opt in "$@"; do
    case $opt in
        -r) rndf=${f_recolor_curves[ $RANDOM % ${#f_recolor_curves[*]}]}
            f_filter_string+=($rndf) 
            ;;
        -m) f_filter_string=("hflip")
            ;;
        -u) f_filter_string=("unsharp")
            ;;
        -c) rndf=${f_scale_crop[ $RANDOM % ${#f_scale_crop[*]}]}
            f_filter_string+=($rndf) 
            ;;
        -s) v_dont_resize=1 # Don't rescale the original video size
            ;;
        -y) o_overwrite=1 # same option as ffmpeg to overwrite existing files
            ;;
        #*) echo "Found $opt"
        #    ;;
    esac
done

# Build filter options from commandline switches
if [[ ${#f_filter_string[@]} > 0 ]]; then
    num=${#f_filter_string[@]} ## number of elements
    i=1
    fc="-vf \""
    for fa in "${f_filter_string[@]}"; do
        [[ $i == $num ]] && fc+="${fa}" || fc+="${fa}," # Don't add a comma to last item.
        ((i++))
    done
    fc+="\""
else
    fc=""
fi

# Video settings from random array elements.
ba=${a_bitrate_b_a[RANDOM%${#a_bitrate_b_a[*]}]}
acodec=${a_codec[RANDOM%${#a_codec[*]}]}
ac=${a_channels_ac[RANDOM%${#a_channels_ac[*]}]}
ar=${a_hertz_ar[RANDOM%${#a_hertz_ar[*]}]}
bv=${v_bitrate_b_v[RANDOM%${#v_bitrate_b_v[*]}]}
vcodec=${v_codec[RANDOM%${#v_codec[*]}]}
[[ $v_dont_resize == 0 ]] && size="-s ${v_resize_s[RANDOM%${#v_resize_s[*]}]}" || size=""
frate=${v_framerate_r[RANDOM%${#v_framerate_r[*]}]}
[[ $o_overwrite == 1 ]] && overwrite_ex="-y " || overwrite_ex=""

command="ffmpeg -hide_banner $overwrite_ex-i \"$infile\" -b:a $ba -acodec $acodec -ac $ac -ar $ar $fc -b:v $bv -vcodec $vcodec $size -r $frate \"$outfile\""

# Just echo for now
echo $command

# complete example command:
# Output a 1080p stereo video that's sharpened and slightly reduces reds
# $ ffmpeg -i file.mp4 -b:a 96k -a:c aac -ar 44100 -ac 2 -vf unsharp,curves=red='0.01/0 1/0.99' -s hd1080 outfile.mkv

exit 0