#!/bin/bash

# Variable initialisation
picture="$1"
colours=""
name="$2"

function finish {
    unset colours
    unset picture
    unset name
}
trap finish EXIT

echo
echo "--------------------> Getting colours..."

cd ../gvcci
python3 extract.py $picture --template templates/nospace.txt
cp gvcci.txt ../ngvccixgogh/
cd ../ngvccixgogh
colours=`cat gvcci.txt`

echo "--------------------> Passing colours into applier script"
echo
echo "Colours: "$colours
echo "Name: "$name
echo

nohup ./ngoghbase.sh $colours $name >/dev/null 2>&1 &
