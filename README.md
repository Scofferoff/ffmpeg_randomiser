# ffmpeg_randomiser

Generates random options for ffmpeg conversion of selected file.
If ffmpeg complains, re run this script to generate new settings, not all settings are compatible.

Usage Examples:<br />
<b>./ffmpeg_randomiser.sh video_to_convert.mp4 converted_file.mkv -s</b><br />
Or using the python script<br />
<b>python3 ./ffmpeg_randomiser.py -i video_to_convert.mp4 -o converted_file.mkv -r -y</b>

<b>Usage help</b><br />
<b>BASH:</b> ./ffmpeg_randomiser.sh -h<br />
<b>Python3:</b> python3 ./ffmpeg_randomiser.py -h

requires ffmpeg - https://ffmpeg.org<br />
$ sudo apt install ffmpeg

<b>Generate 5 different videos in bash</b><br />
for i in {1..5}; do ./ffmpeg_randomiser.sh input_video.mp4 output_$i.mp4; done

<b>youtube-dl</b> is a good utility to download videos from many social media platforms<br />
https://youtube-dl.org/
