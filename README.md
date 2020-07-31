# webp2gif

### webp2gif.sh

Improved version of https://unix.stackexchange.com/questions/419761/webp-animation-to-gif-animation-cli

Dependent packages: webp, imagemagick

use apt install webp imagemagick




### webp2gif.py

Python version of webp2gif.sh, in memory, faster

Dependent packages: webp, imageio

use python3 -m pip install webp imageio




### webp2gif.cpp

c++ version of webp2gif, much faster

using gif-h at https://github.com/charlietangora/gif-h

Dependent packages: libwebpdemux2

use apt install libwebpdemux2 build-essential g++

and

g++ webp2gif.cpp -o webp2gif -lwebp -lwebpdemux

to build
