# ffmpeg_randomiser

selects random options for ffmpeg conversion of selected file.

Usage Example: ./ffmpeg_randomiser.sh video_to_convert.mp4 converted_file.mkv

Usage printout
./ffmpeg_randomiser.sh -h
NOTE: No current additional options other than in and out file.

requires ffmpeg - https://ffmpeg.org
$ sudo apt install ffmpeg

<b>Generate 5 different videos</b>
for i in {1..5}; do ./ffmpeg_randomiser.sh input_video.mp4 output_$i.mp4; done