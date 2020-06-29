#!/usr/bin/zsh

DELAY=${DELAY:-10}
LOOP=${LOOP:-0}
n=`webpinfo -summary $1 | grep frames | sed -e 's/.* \([0-9]*\)$/\1/'`
duration=$(webpinfo -summary $1 | grep Duration | head -n2 | tail -n1 | sed -e 's/.* \([0-9]*\)$/\1/')
fps=`expr 1000 / $duration`
pfx="${1%.*}"
echo $pfx
pfx=`echo -n $1 | sed -e 's/^\(.*\).webp$/\1/'`
if [ -z $pfx ]; then
	pfx=$1
fi
mkdir -p "workdir_$pfx"

echo "converting $n frames from $1"

for ((i=1; i<=$n; i++)); do
	webpmux -get frame $i $1 -o $pfx.$i.webp
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

cp $pfx.1.webp workdir_$pfx/ov_$pfx.1.webp

for ((i=2; i<=$n; i++)); do
	i_p=`expr $i - 1`
	composite -gravity NorthWest -geometry +$off_x[$i]+$off_y[$i] $pfx.$i.webp workdir_$pfx/ov_$pfx.$i_p.webp workdir_$pfx/ov_$pfx.$i.webp
done
rm $pfx.[0-9]*.webp

#convert $pfx.*.png -delay $DELAY -loop $LOOP $pfx.gif
ffmpeg -framerate $fps -i workdir_$pfx/ov_$pfx.%d.webp $pfx.gif -y &> /dev/null
rm -rf workdir_$pfx
#ffmpeg -framerate $fps -i $pfx.%d.png $pfx.gif -y
#rm ov_$pfx.[0-9]*.webp $pfx.[0-9]*.webp

unset off_x off_y
