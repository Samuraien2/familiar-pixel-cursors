#!/usr/bin/env bash
SIZES=${SIZES:-"16 32 48 64"}

cd -- $(dirname -- "$0")

require() { command -v $1 &>/dev/null || exec echo missing dependency: $1; }

require xcursorgen
require ffmpeg

OUT=./familiar-pixel-cursors
tmp=$(mktemp -d)

cursor() {
	ffmpeg -y -v error -i all.png -vf crop=16:16:$1 $tmp/$2.png
	> $tmp/conf
	for size in $SIZES; do
		factor=$((size / 16))
		if [[ $size == 16 ]]; then
			ln $tmp/$2.png $tmp/$2-16x.png
		else
			ffmpeg -y -v error -i $tmp/$2.png -vf scale=$size:$size:flags=neighbor $tmp/$2-${size}x.png
		fi
		echo $size $((${3} * factor)) $((${4} * factor)) $tmp/$2-${size}x.png >>$tmp/conf
	done
	xcursorgen $tmp/conf $OUT/cursors/$5
	for alias in ${@:6}; do
		ln -s $5 $OUT/cursors/$alias
	done
	echo $2
}

animation() {
	frames=$1
	for frame in $(seq $frames); do
		echo $3-$frame
		ffmpeg -y -v error -i all.png -vf crop=16:16:$((($frame - 1) * 16)):$2 $tmp/$3-$frame.png
	done

	> $tmp/conf
	for size in $SIZES; do
		factor=$((size / 16))
		for frame in $(seq $frames); do
			if [[ $size == 16 ]]; then
				ln $tmp/$3-$frame.png $tmp/$3-$frame-16x.png
			else
				ffmpeg -y -v error -i $tmp/$3-$frame.png -vf scale=$size:$size:flags=neighbor $tmp/$3-$frame-${size}x.png
			fi
			echo $size $((${4} * factor)) $((${5} * factor)) $tmp/$3-$frame-${size}x.png $6 >>$tmp/conf
		done
	done

	xcursorgen $tmp/conf $OUT/cursors/$7
	for alias in ${@:8}; do
		ln -s $5 $OUT/cursors/$alias
	done
	echo $3
}

rm -rf $OUT
mkdir -p $OUT/cursors
cp index.theme $OUT/

cursor 0:0 arrow 0 0 left_ptr
cursor 16:0 hand 3 0 hand1 pointer
cursor 32:0 text 2 4 xterm
cursor 48:0 grab 4 5 grab
cursor 64:0 grabbing 4 3 grabbing move
cursor 80:0 zoom-in 4 4 zoom-in
cursor 96:0 zoom-out 4 4 zoom-out

cursor 0:16 ns-resize 2 5 ns-resize sb_v_double_arrow double_arrow row-resize
cursor 16:16 ew-resize 5 2 ew-resize sb_h_double_arrow col-resize
cursor 32:16 nesw-resize 4 4 nesw-resize ne-resize bottom_left_corner top_right_corner
cursor 48:16 nwse-resize 4 4 nwse-resize nw-resize bottom_right_corner top_left_corner
cursor 64:16 up 2 0 sb_up_arrow top_side based_arrow_up
cursor 80:16 down 2 8 sb_down_arrow bottom_side based_arrow_down
cursor 96:16 left 0 2 sb_left_arrow left_side
cursor 112:16 right 8 2 sb_right_arrow right_side

cursor 0:32 move 5 5 all-resize fleur

cursor 0:48 pencil 0 0 pencil
cursor 16:48 wrong 3 3 not-allowed no-drop
cursor 32:48 help 0 0 help question_arrow

animation 16 64 progress 0 4 50 progress
animation 16 80 wait 7 7 50 wait

rm -rf $tmp

echo "Built for sizes: $SIZES in $OUT"
