#!/bin/bash

default_path="/home/scott/.Xresources"

# Variable initialisation
picture="$1"
colours=""
path="$2"
echo
if [ -z "$path" ]; then
	path="$default_path"
	echo "Using default path= ""$default_path"
else
	echo "Using path= ""$path"
fi
no_theme_count="0"
path_bk="$path""_nl_bk"
path_old_bk="$path""_old"
line=""
end="7"
start=""

bf_diff=""
bg=""
size=""
tmp=""
fg=""
lc=""
start_colours=""
end_colours=""

declare -a colour_array=()
declare -a file_contents=()
declare -a actual_file=()
declare -a new_file=()

function finish {
    unset colours
    unset picture
    unset name
    unset colour_array
    unset path
    unset path_bk
  	unset path_old_bk
    unset line
    unset end
    unset start
}
trap finish EXIT

function check_file_exists {
	echo
	if [ -f "$path" ]; then
		echo "FOUND FILE"
	else
		echo "FILE NOT FOUND"
		exit
	fi
	echo
}

function create_new_backup {
	if [ -f "$path_bk" ]; then
		echo "Existing backup found!"
		echo "Forcing a new backup now..."
		rm "$path_bk"
	fi
	cp "$path" "$path_bk"
	echo
	echo "Backup created!"
	echo
}

function check_for_backup {
	if [ -f "$path_bk" ]; then
		rm "$path"
		cp "$path_bk" "$path"
	else
		echo "No backup found! Creating new one..."
		create_new_backup
	fi
}

function create_double_backup {
	if ! [ -f "$path_old_bk" ]; then
		cp "$path" "$path_old_bk"
	fi
}

function read_file {
	# Read the whole file
	while IFS='' read -r line || [[ -n "$line" ]]; do
		# Doesn't include empty lines and comments
		if ! [ -z "$line" ] && ! [ "${line:0:1}" == "!" ]; then
			file_contents+=( "$line" )
		fi
		actual_file+=( "$line" )
	done < "$path"
	size="$[ ${#actual_file[@]} - 1 ]"
}

function find_theme {
	tmp=""

	for i in `seq 0 $size`; do
		tmp="${actual_file[$i]}"
		if [ "${tmp:6:10}" == "background" ]; then
			bg="$i"
		elif [ "${tmp:6:10}" == "foreground" ]; then
			fg="$i"
		elif [ "${tmp:1:7}" == "color15" ]; then
			lc="$i"
		else
			no_theme_count="$[ $no_theme_count + 1 ]"
		fi
	done
}

function get_bf_diff {
	if [ "$[ $bg - $fg ]" -lt "0" ]; then
		bf_diff="$[ $fg - $bg ]"
	else
		bf_diff="$[ $bg - $fg ]"
	fi
}

function find_theme_start {
	if [ -z "$bg" ] || [ -z "$fg" ]; then
		start_colours="$[ $size + 1 ]"
	else
		if [ "$bg" -eq "$[ $lc - 16 - $bf_diff ]" ]; then
			echo "bg is below fg, & is last cmd"
			start_colours="$[ $fg - 1 ]"
		elif [ "$fg" -eq "$[ $lc - 16 - $bf_diff ]" ]; then
			echo "fg is below bg, & is last cmd"
			start_colours="$[ $bg - 1 ]"
		else
			echo "$[ $lc - 16 - $bf_diff ]"
			echo "Something went wrong... :/"
		fi
		end_colours="$lc"
	fi
}

function get_new_colours {
	if [ -f "gvcci.txt" ]; then
		echo "Removed old theme colour codes"
		rm "gvcci.txt"
	fi
	cd ../gvcci
	python3 extract.py $picture --template templates/nospace.txt
	mv gvcci.txt ../ngvccixgogh/gvcci.txt
	cd ../ngvccixgogh
	colours=`cat gvcci.txt`
}

function set_colour_array {
	file=`cat "$path"`
	for i in `seq 0 $[ 7 * 17 ]`; do
		start="$[ $i * 7 ]"
		colour_array+=( "${colours:$start:$end}" )
	done
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use file_contents to verify bg, fg and lc and such
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#function check_lc_is_last {
#	if [ "$lc" -eq "$size" ]; then
#		echo "color15 is the last thing in the file"
#	fi
#}

function write_to_file {
	rm "$path"
	touch "$path"

	for i in `seq 0 $[ $start_colours - 1 ]`; do
		echo "${actual_file[$i]}" >> "$path"
	done

	if [ "$[ $no_theme_count - 1 ]" -eq "$size" ]; then
		echo "" >> "$path"
	fi

	echo "urxvt*background: ""${colour_array[0]}" >> "$path"
	echo "urxvt*foreground: ""${colour_array[1]}" >> "$path"
	for i in `seq 2 17`; do
		echo "*color""$[ $i - 2 ]"": ""${colour_array[$i]}" >> "$path"
	done
}

check_file_exists
create_new_backup
#check_for_backup
create_double_backup
read_file
find_theme
if ! [ "$[ $no_theme_count - 1 ]" -eq "$size" ]; then
	echo
	echo "THEME DETECTED"
	echo
	get_bf_diff
fi
find_theme_start
get_new_colours
set_colour_array
write_to_file

echo "Theme installed!"
xrdb "$path"
echo "Re-initialised database"
echo
echo "Colours: "$colours
echo "Name: "$name
echo
