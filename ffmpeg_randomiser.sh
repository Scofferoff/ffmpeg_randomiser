#!/bin/bash

# DEBUG


# Run ffmpeg in various ways to obfusticate the original content 
# In theory this may slow down automatic algorithmic identification from social media platforms for censorship.

# Use only with landscape videos for now

# Arrays of options
# Array naming: AVorF_ReadableName_CommandlineOption
# Example:      $v_bitrate_b_v      -- b_v means b:v
# All values, even Ints are Strings due to them being concatenated to a commandline string
# Zero or "copy" values mean keep Output settings as Input, No change

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
f_filter_string=()
f_recolor_curves=("b='0/0 0.99/0.95'" "r=0/0.1 0.99/1:b=0/0.1 0.99/1") # change colour encoding
f_flipH_hflip=0
f_sharpen_unsharp=0 # This isn't useful but will change pixels per frame, therefore the overall content.
f_crop_crop=("1918:1078:2:2" "1278:718:2:2" "1916:" "10") # TODO: CHANGE THIS TO ZOOM BY A TINY AMOUNT

# GENERAL SETTINGS
fixed_size_fs="0" # 0 or 1: Generate a file of fixed size, NOT IDEAL FOR THIS SITUATION

RANDOM=$$$(date +%s)

# CONFIGURE THE COMMAND OPTIONS

usage="Usage: ./ffmpeg_randomiser.sh input_filename new_filename.mp4 [-r] [-m] [-s] [-c]
        # [options] are optional
        # new_filename can have extensions MP4 or MKV, this determines the final format
        # Unless you want to copy the input_file format, then new_filename should have the identical extension.
        # Existing new filenames will create a prompt to overwrite.
        # new_filename can be e.g dir1/dir2/new_filename, as long as those directories exist

        -c = crop the image slightly, changes edge pixels.
        -m = mirror, flips the video horizontally
        -r = recolor randomly, minimal color balance changes
        -s = runs a Sharpen filter on each frame, may not change anything visually, but changes each frame"

case "$1" in
    "-h"|"--help"|"/?"|"?")
        printf "$usage"
        exit 0
        ;;
esac

if [ ! -f "$1" ]; then
    printf "ERROR: File not found\n $usage"
    exit 1
fi

# FUNCTIONS

#

infile="$1"
infile_ext="${outfile##*.}"

outfile="$2"
outfile_ext="${outfile##*.}"
# remove the first 2 options
#shift; shift

# Some optional options are optional
# Adds filter options to the last array index, probably too much work here
for opt in "$@"; do
    case $opt in
        -r) rndf=${f_recolor_curves[ $RANDOM % ${#f_recolor_curves[*]}]}
            f_filter_string=(${#f_filter_string[@]} $rndf ) 
            ;;
        -m) f_filter_string=(${#f_filter_string[@]} "hflip" )
            ;;
        -s) f_filter_string=(${#f_filter_string[@]} "unsharp" )
            ;;
        -c) rndf=${f_crop_crop[ $RANDOM % ${#f_crop_crop[*]}]}
            f_filter_string=(${#f_filter_string[@]} $rndf ) 
            ;;
        #*) echo "Found $opt"
        #    ;;
    esac
done

# TODO
# Select random values from each array
# Build filters string
# Consider making random array element selection a function

# All the randomness

o1=${a_bitrate_b_a[RANDOM%${#a_bitrate_b_a[*]}]}
o2=${a_codec[RANDOM%${#a_codec[*]}]}
o3=${a_channels_ac[RANDOM%${#a_channels_ac[*]}]}
o4=${a_hertz_ar[RANDOM%${#a_hertz_ar[*]}]}
o5=${v_bitrate_b_v[RANDOM%${#v_bitrate_b_v[*]}]}
o6=${v_codec[RANDOM%${#v_codec[*]}]}
o7=${v_resize_s[RANDOM%${#v_resize_s[*]}]}
o8=${v_framerate_r[RANDOM%${#v_framerate_r[*]}]}

command="ffmpeg -hide_banner -i $infile -b:a $o1 -acodec $o2 -ac $o3 -ar $o4 -b:v $o5 -vcodec $o6 -s $o7 -r $o8 $outfile"

echo $command

# complete example command:
# Output a 1080p stereo video that's sharpened and slightly reduces reds
# $ ffmpeg -i file.mp4 -b:a 96k -a:c aac -ar 44100 -ac 2 -vf unsharp,curves=red='0.01/0 1/0.99' -s hd1080 outfile.mkv

exit 0