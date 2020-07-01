#! /usr/bin/env python3

import sys
import imageio
import webp
from glob import glob
from multiprocessing import Pool

def convert_webp2gif(src_webp):
    try:
        with open(src_webp, 'rb') as src_f:
            webp_data = webp.WebPData.from_buffer(src_f.read())
            dec = webp.WebPAnimDecoder.new(webp_data)
            
            list_frame=[]
            list_dur=[]
            prev_timestamp=0

            for frame, timestamp_ms in dec.frames():
                list_frame.append(frame)
                list_dur.append(timestamp_ms/1000.0 - prev_timestamp)
                prev_timestamp = timestamp_ms/1000.0

        with imageio.get_writer(src_webp.replace('.webp', '.gif'), mode='I', duration=list_dur) as dst_writer:
            for frame, duration_ms in zip(list_frame, list_dur):
                dst_writer.append_data(frame)
    except Exception as e:
        print(f"{ERR_RED}error while processing {src_webp}: {e}", file=sys.stderr)
        return -1
    return 0



if sys.stderr.isatty():
    ERR_RED = '\033[0;31m'
else:
    ERR_RED = '\033[0m'

srclist=[]
for arg in sys.argv[1:]:
    if arg.endswith('.webp'):
        srclist.append(arg)
    else:
        print(f"{ERR_RED}argument error!: {arg}", file=sys.stderr)
        print(f"{ERR_RED}usage: webp2gif.py FILE1.webp FILE2.webp ...", file=sys.stderr)
        print(f"{ERR_RED}or", file=sys.stderr)
        print(f"{ERR_RED}       webp2gif.py */*.webp ...", file=sys.stderr)
        sys.exit(0)

with Pool(4) as p:
    p.map(convert_webp2gif, srclist)
