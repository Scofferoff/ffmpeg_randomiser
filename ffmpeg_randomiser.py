#!/usr/bin/python3

# ffmpeg video randomizer
import sys, getopt
import random

def rndIndex(arr):
        # returns a random array index
        rnd= random.randint (0, len(arr)-1)
        return arr[rnd]


def main(argv):
        # AUDIO
        a_bitrate_b_a = ("96k", "128k", "192k", "256k", "320k") # bits/s
        a_codec = ("copy", "flac", "aac", "ac3")
        a_channels_ac = ("1", "2") # Add more if you really want 2.1+ This is intended for Social media shares
        a_hertz_ar = ("16000", "44100", "48000", "96000")

        # VIDEO
        v_bitrate_b_v = ("350k", "700k", "1200k", "2500k", "5000k")
        v_codec = ("libx264", "libx264rgb", "libx265", "libxvid") # ffmpeg -encoders
        v_resize_s = ("hd720", "hd1080", "wxga", "wvga", "wsxga", "wuxga") # predefined video resolutions, might not work with Portrait videos?
        # ^ problematic if upscaling, but only in terms of visual quality/bluring
        v_framerate_r = ("ntsc", "pal", "film", "ntsc-film") # convert framerates
        #v_wrapper = ("mp4", "mkv", "webm", "mov") # Anything that suits the encoders, ffmpeg will use the out_file to determine this part

        # FILTERS
        f_filter_string = [] # Array to hold optional filters
        # Read ffmpeg documentation on curves filter
        f_recolor_curves = ("curves=b='0/0 0.99/0.95'", "curves=r=0/0.1 0.99/1:b=0/0.1 0.99/1") # change colour values
        # Zooming is a 2 step filter of scaling and cropping
        f_scale_crop = ("scale=1.02*iw:-1,crop=iw/1.02:ih/1.02", "scale=0.98*iw:-1,crop=iw/0.98:ih/0.98") # Can simplify this by just selecting a number and inserting to final string.

        usage="""Usage: ./ffmpeg_randomiser.sh -i input_filename -o new_filename.mp4 [-options]

        # new_filename can have extensions MP4,MKV,WEBM,MOV this determines the final format
        # full pathnames can be used, as long as those directories exist, use quotes for safety!
        [REQUIRED]
        -i input video fileath
        -o output filepath

        [OPTIONS] space seperated list: e.g -r -m -y
        -c = crop the image slightly, changes edge pixels.
        -m = mirror, flips the video horizontally
        -r = recolor randomly, minimal color balance changes
        -u = runs a Sharpen filter on each frame, SLOW
        -s = Don't randomly resize the video. The potential upscaling reduces quality.
        -y = Overwrite existing files without prompting."""

        infile=''
        outfile=''
        overwrite=''
        v_dont_resize=1
        filters=''
        size=''
        
        try:
                opts, arg = getopt.getopt(argv,"i:o:scrumyh", ["if=", "of="])
        except getopt.GetoptError:
                print('Invalid options\nffmpeg_randomiser.py -i <inputfile> -o <converted filename>\nffmpeg_randomiser.py -h for more info')
                sys.exit(2)
        for opt, arg in opts:
                if opt == '-h':
                        print(usage)
                        sys.exit(1)
                elif opt in ("-i", "--if"):
                        infile=arg
                elif opt in ("-o", "--of"):
                        outfile=arg
                elif opt == "-r":
                        # recolor option
                        index = random.randint(0, len(f_recolor_curves)-1)
                        f_filter_string.append( f_recolor_curves[ index ] )
                elif opt == "-m":
                        # mirror
                        f_filter_string.append('hflip')
                elif opt == "-c":
                        # crop/scale
                        index = rndIndex(f_scale_crop)
                        f_filter_string.append( index ) 
                elif opt == "-s":
                        # dont change dimensions
                        v_dont_resize = 0
                elif opt == "-y":
                        # overwrite without asking
                        overwrite = '-y '
                elif opt == "-u ":
                        # unsharp filter
                        f_filter_string.append("unsharp")

        if len(f_filter_string):
                for fs in range(len(f_filter_string)):
                        filters += f_filter_string[fs]
                        if fs != len(f_filter_string)-1:
                                filters += "," ## Comma seperate each filter
                #print(filters)

        #else:
        #        print("No filters being used")

        # choose the settings for the conversion
        ba = rndIndex(a_bitrate_b_a)
        acodec = rndIndex(a_codec)
        ac = rndIndex(a_channels_ac)
        ar = rndIndex(a_hertz_ar)
        bv = rndIndex(v_bitrate_b_v)
        vcodec = rndIndex(v_codec)
        if v_dont_resize == 1: size = "-s " + rndIndex(v_resize_s) + " "
        fr = rndIndex(v_framerate_r)

        # build the command, could be prettier if generated from an array.
        command = "ffmpeg -hide_banner " + \
                overwrite + \
                "-i \"" + infile + "\" " + \
                "-b:a " + ba + " " + \
                "-acodec " + acodec + " " + \
                "-ac " + ac + " " + \
                "-ar " + ar + " " + \
                "-vf \"" + filters + "\" " + \
                "-b:v " + bv + " " + \
                "-vcodec " + vcodec + " " + \
                size + \
                "-r " + fr + " " + \
                "\"" + outfile + "\""
        print (command)

if __name__ == "__main__":
        main(sys.argv[1:])