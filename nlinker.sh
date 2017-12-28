#!/bin/bash

# Variable initialisation
pic_path="$1"
ext_len="${pic_path#*.*}"
ext_len="${#ext_len}"
ext_len="$[ $ext_len - $ext_len - $ext_len - 1 ]"
path_len="${pic_path%*/*}"
path_len="${#path_len}"
path_len="$[ $path_len + 1 ]"
picture="${pic_path:$path_len:$ext_len}"
colours=""
name="$2"
user="$(whoami)"

function finish {
    unset colours
    unset picture
    unset name
    unset user
    unset path_len
    unset ext_len
    unset pic_path
}
trap finish EXIT

echo
echo "--------------------> Getting colours..."

cd ../gvcci
#python3 extract.py $picture --template templates/nospace.txt
./gvcci.sh $pic_path --template templates/nospace.txt
#cp gvcci.txt ../ngvccixgogh/
cd ../ngvccixgogh
cp "/home/$user/.gvcci/themes/$picture/nospace.txt" "gvcci.txt"
colours=`cat gvcci.txt`

echo "--------------------> Passing colours into applier script"
echo
echo "Colours: "$colours
echo "Name: "$name
echo

nohup ./ngoghbase.sh $colours $name >/dev/null 2>&1 &
