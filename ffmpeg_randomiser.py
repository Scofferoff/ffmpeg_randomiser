#!/usr/bin/python3

# ffmpeg video randomizer
import sys, getopt
import random

def main(argv):
        # AUDIO
        a_bitrate_b_a = ("96k", "128k", "192k", "256k", "320k") # bits/s
        a_codec = ("copy", "flac", "aac", "ac3", "vorbis", "libvorbis")
        a_channels_ac = ("1", "2") # Add more if you really want 2.1+ This is intended for Social media shares
        a_hertz_ar = ("16000", "44100", "48000", "96000")

        # VIDEO
        v_bitrate_b_v = ("copy", "350k", "700k", "1200k", "2500k", "5000k")
        v_codec = ("copy", "libx264", "libx264rgb", "libx265", "libxvid", "h264_v4l2m2m") # ffmpeg -encoders
        v_resize_s = ("hd720", "hd1080", "wxga", "wvga", "wsxga", "wuxga") # predefined video resolutions, might not work with Portrait videos?
        # ^ problematic if upscaling, but only in terms of visual quality/bluring
        v_framerate_r = ("ntsc", "pal", "film", "ntsc-film") # convert framerates
        v_wrapper = ("mp4", "mkv", "webm", "mov") # Anything that suits the encoders, ffmpeg will use the out_file to determine this part

        # FILTERS
        f_filter_string = [] # Array to hold optional filters
        # Read ffmpeg documentation on curves filter
        f_recolor_curves = ("curves=b='0/0 0.99/0.95'", "curves=r=0/0.1 0.99/1:b=0/0.1 0.99/1") # change colour values
        # Zooming is a 2 step filter of scaling and cropping
        f_scale_crop = ("scale=1.01*iw:-1,crop=iw/1.01:ih/1.01", "scale=0.99*iw:-1,crop=iw/0.99:ih/0.99") # Can simplify this by just selecting a number and inserting to final string.

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
                -y = Overwrite existing files without prompting.
                """

        infile=''
        outfile=''
        overwrite=''
        v_dont_resize=1
        
        try:
                opts, arg = getopt.getopt(argv,"i:o:crusmy", ["if=", "of="])
        except getopt.GetoptError:
                print('ffmpeg_randomiser.py -i <inputfile> -o <converted filename>')
                sys.exit(2)
        for opt, opts in opts:
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
                        index = random.randint(0, len(f_scale_crop)-1)
                        f_filter_string.append( f_scale_crop[ index ] ) 
                elif opt == "-s":
                        # dont change dimensions
                        v_dont_resize = 0
                elif opt == "-y":
                        # overwrite without asking
                        overwrite = '-y'
                elif opt == "-u ":
                        # unsharp filter
                        f_filter_string.append("unsharp")

if __name__ == "__main__":
        main(sys.argv[1:])