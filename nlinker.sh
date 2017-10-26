#!/bin/bash

colours=""
picture="$1"
name="$2"
out=""
tmp=""
declare -a col_arr=()
end=8

touch output.txt

function finish {
    unset colours
    unset piccture
    unset name
    unset out
    unset tmp
    unset col_arr
    unset end
    unset start
}
trap finish EXIT

echo
echo "--------------------> Getting colours..."

# Will need to adjust this to allow for arguments to be sent to extract.py
python3 extract.py $picture >output.txt

out=`cat output.txt`

tmp="${out#*Background*}"
tmp="${tmp:0:8}"
col_arr+=( $tmp )

tmp=""
tmp="${out#*Foreground*}"
tmp="${tmp:0:8}"
col_arr+=( $tmp )

# 8 accent colours, 7 chars in length (for hex codes)
for j in `seq 0 1`; do
    if [ "$j" -eq "0" ]; then
        out="${out#*Normal*}"
    else
        out="${out#*Bright*}"
    fi
    for i in `seq 0 $[ 7 ]`; do
        start=$[ $i * 8 ]
        tmp=""
        tmp="${out:$start:$end}"
        col_arr+=( $tmp )
    done
done

arr_len="${#col_arr[@]}"
for i in `seq 0 $arr_len`; do
    colours="$colours""${col_arr[$i]}"
done

echo "--------------------> Passing colours into applier script"
echo
echo "Colours: "$colours
echo "Name: "$name
echo

nohup ./ngoghbase.sh $colours $name >/dev/null 2>&1 &

echo "--------------------> Cleaning up..."
rm output.txt

