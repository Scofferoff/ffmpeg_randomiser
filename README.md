# ffmpeg_randomiser

Generates random options for ffmpeg conversion of selected file.

Usage Example: <b>./ffmpeg_randomiser.sh video_to_convert.mp4 converted_file.mkv -s</b>

<b>Usage printout</b><br />
./ffmpeg_randomiser.sh -h<br />
NOTE: No current additional options other than in and out file.<br />
Read the script header for more even info<br />

requires ffmpeg - https://ffmpeg.org<br />
$ sudo apt install ffmpeg

<b>Generate 5 different videos</b><br />
for i in {1..5}; do ./ffmpeg_randomiser.sh input_video.mp4 output_$i.mp4; done

For windows users to run this script, it will be helpful to look at enabling WSL & installing Ubuntu from the App store

<b>youtube-dl</b> is a good utility to download videos from many social media platforms<br />
https://youtube-dl.org/