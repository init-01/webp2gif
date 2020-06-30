#! /usr/bin/env python3

import sys
import imageio
import webp

if len(sys.argv) == 2:
    src_webp=sys.argv[1]
else:
    print("argument error")
    print("usage: webp2gif.py src_path")
    sys.exit(0)

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
