# OBS4Pi. Installing FFMPEG and OBS Studio for the Raspberry Pi 4 ![Build passed](https://img.shields.io/badge/build-passed-green)

This script is an attempt for building FFMPEG (n4.3.2) and OBS Studio (26.1.1) on a Raspberry Pi 4. It grabs and copypasta from other building scripts I found but running without success.

If you're interested on this topic I suggest you to read this interesting thread, [OBS Raspberry Pi Build Instructions](https://obsproject.com/forum/threads/obs-raspberry-pi-build-instructions.115739/). It includes a lot of comments and suggestions to help to build OBS on a Raspberry Pi.

Maybe this script will not work tomorrow or next week, so do feel free to open an issue to warning me.

<!--
## Cygwin + headless Raspberry Pi 4

Additionally you can read some information for running OBS Studio on a headless raspy using cygwin:

https://www.lanoiadimuu.it/2013/04/raspberry-pi-x11-forwarding-with-cygwin/

https://desertbot.io/blog/headless-raspberry-pi-4-lite-remote-desktop-upgrade

## Some minor issues to take care of

Finally, if you're editing this script under dos environment, you'll get this error related to EOL.

https://stackoverflow.com/questions/14219092/bash-script-and-bin-bashm-bad-interpreter-no-such-file-or-directory

sed -i -e 's/\r$//' scriptname.sh

https://emacs.stackexchange.com/questions/5779/how-to-convert-dos-windows-newline-characters-to-unix-format-within-gnu-emacs
-->
