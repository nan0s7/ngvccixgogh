#!/bin/bash

# Variable initialisation
user="$(whoami)"
default_path="/home/""$user""/.Xresources"
terminal="$(xdotool getactivewindow getwindowname)"
pic_path="$1"
ext_len="${pic_path#*.*}"
ext_len="${#ext_len}"
ext_len="$[ $ext_len - $ext_len - $ext_len - 1 ]"
path_len="${pic_path%*/*}"
path_len="${#path_len}"
path_len="$[ $path_len + 1 ]"
picture="${pic_path:$path_len:$ext_len}"
colours=""
path="$2"
echo
if [ -z "$path" ]; then
	path="$default_path"
	echo "Using default path=""$default_path"
else
	echo "Using path=""$path"
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

finish() {
    unset colours
    unset pic_path
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

check_file_exists() {
	echo
	if [ -f "$path" ]; then
		echo "FOUND FILE"
	else
		echo "FILE NOT FOUND"
		exit
	fi
	echo
}

create_new_backup() {
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

create_double_backup() {
	if ! [ -f "$path_old_bk" ]; then
		cp "$path" "$path_old_bk"
	fi
}

read_file() {
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

find_theme() {
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

get_bf_diff() {
	if [ "$[ $bg - $fg ]" -lt "0" ]; then
		bf_diff="$[ $fg - $bg ]"
	else
		bf_diff="$[ $bg - $fg ]"
	fi
}

find_theme_start() {
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

get_new_colours() {
	if [ -f "gvcci.txt" ]; then
		echo "Removed old theme colour codes"
		rm "gvcci.txt"
	fi
	cd ../gvcci
#	python3 extract.py $pic_path --template templates/nospace.txt
	./gvcci.sh $pic_path --template templates/nospace.txt
	cd ../ngvccixgogh
	cp "/home/""$user""/.gvcci/themes/""$picture""/nospace.txt" "gvcci.txt"
	colours=`cat gvcci.txt`
}

set_colour_array() {
	file=`cat "$path"`
	for i in `seq 0 $[ 7 * 17 ]`; do
		start="$[ $i * 7 ]"
		colour_array+=( "${colours:$start:$end}" )
	done
}

set_gogh_colours() {
	BACKGROUND_COLOR="${colour_array[0]}"
	FOREGROUND_COLOR="${colour_array[1]}"
	CURSOR_COLOR="$FOREGROUND_COLOR"
	PROFILE_NAME=""  #"$name"
	COLOR_01="${colour_array[2]}"
	COLOR_02="${colour_array[3]}"
	COLOR_03="${colour_array[4]}"
	COLOR_04="${colour_array[5]}"
	COLOR_05="${colour_array[6]}"
	COLOR_06="${colour_array[7]}"
	COLOR_07="${colour_array[8]}"
	COLOR_08="${colour_array[9]}"
	COLOR_09="${colour_array[10]}"
	COLOR_10="${colour_array[11]}"
	COLOR_11="${colour_array[12]}"
	COLOR_12="${colour_array[13]}"
	COLOR_13="${colour_array[14]}"
	COLOR_14="${colour_array[15]}"
	COLOR_15="${colour_array[16]}"
	COLOR_16="${colour_array[17]}"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use file_contents to verify bg, fg and lc and such
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

write_to_file() {
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

apply_non_urxvt() {
	SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	PARENT_PATH="$(dirname "$SCRIPT_PATH")"

	if [ -e $PARENT_PATH"/apply-colors.sh" ]; then
		source $PARENT_PATH"/apply-colors.sh"
	else
		source <(wget -O - https://raw.githubusercontent.com/Mayccoll/Gogh/master/apply-colors.sh)
	fi
}

if [ "$terminal" == "urxvt" ]; then
	check_file_exists
	create_new_backup
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

	xrdb "$path"
else
	get_new_colours
	set_colour_array
	set_gogh_colours
	apply_non_urxvt
fi

echo
echo "Theme installed!"
echo
echo "Colours: "$colours
