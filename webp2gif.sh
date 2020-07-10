#!/usr/bin/zsh

n=`webpinfo -summary $1 | grep frames | sed -e 's/.* \([0-9]*\)$/\1/'`
duration=`webpinfo -summary $1 | grep Duration | head -n2 | tail -n1 | sed -e 's/.* \([0-9]*\)$/\1/'`
fps=`expr 1000 / $duration`
pfx="${1%.*}"
pfx=`echo -n $1 | sed -e 's/^\(.*\).webp$/\1/'`
if [ -z $pfx ]; then
	pfx=$1
fi
mkdir -p "workdir_$pfx"

for i in `seq -f "%05g" 1 $n`; do
	webpmux -get frame $((i)) $1 -o workdir_$pfx/$i.webp &> /dev/null
done

#composite to remove transparent background

off_x=()
off_y=()

while read line; do
	off_x+=("$line")
done <<< `webpinfo animated-webp-supported.webp | grep Offset_X | sed 's/^[ \t]*Offset_X: //g'`

while read line; do
	off_y+=("$line")
done <<< `webpinfo animated-webp-supported.webp | grep Offset_Y | sed 's/^[ \t]*Offset_Y: //g'`

cp workdir_$pfx/00001.webp workdir_$pfx/ov_00001.webp

for i in `seq -f "%05g" 2 $n`; do
	printf -v i_p "%05d" `expr $((i)) - 1`
	composite -gravity NorthWest -geometry +$off_x[$((i))]+$off_y[$((i))] workdir_$pfx/$i.webp workdir_$pfx/ov_$i_p.webp workdir_$pfx/ov_$i.webp &> /dev/null
done

#ffmpeg -framerate $fps -i workdir_$pfx/ov_%05d.webp ${pfx}.gif -y &> /dev/null
convert -delay ${duration}x1000 -loop 0 workdir_$pfx/ov_*.webp ${pfx}.gif &> /dev/null
rm -rf workdir_$pfx
