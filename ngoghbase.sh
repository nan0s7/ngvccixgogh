#!/bin/bash

string=""
name=""
start="0"
#end="0"
end="7"
declare -a string_array=()

string="$1"
name="$2"

for i in `seq 0 $[ 7 * 17 ]`; do
	start=$[ $i * 7 ]
	string_array+=( "${string:$start:$end}" )
done

# ==================== CONFIG THIS ============================== #
COLOR_01="${string_array[2]}"           # HOST
COLOR_02="${string_array[3]}"           # SYNTAX_STRING
COLOR_03="${string_array[4]}"           # COMMAND
COLOR_04="${string_array[5]}"           # COMMAND_COLOR2
COLOR_05="${string_array[6]}"           # PATH
COLOR_06="${string_array[7]}"           # SYNTAX_VAR
COLOR_07="${string_array[8]}"           # PROMP
COLOR_08="${string_array[9]}"           #

COLOR_09="${string_array[10]}"          #
COLOR_10="${string_array[11]}"          # COMMAND_ERROR
COLOR_11="${string_array[12]}"          # EXEC
COLOR_12="${string_array[13]}"          #
COLOR_13="${string_array[14]}"          # FOLDER
COLOR_14="${string_array[15]}"          #
COLOR_15="${string_array[16]}"          #
COLOR_16="${string_array[17]}"          #

BACKGROUND_COLOR="${string_array[0]}"   # Background Color
FOREGROUND_COLOR="${string_array[1]}"   # Text
CURSOR_COLOR="$FOREGROUND_COLOR"        # Cursor
PROFILE_NAME="$name"
# =============================================================== #

# =============================================================== #
# | Apply Colors                                                | #
# =============================================================== #
function gogh_colors () {
    echo ""
    echo -e "\e[0;30m█████\\e[0m\e[0;31m█████\\e[0m\e[0;32m█████\\e[0m\e[0;33m█████\\e[0m\e[0;34m█████\\e[0m\e[0;35m█████\\e[0m\e[0;36m█████\\e[0m\e[0;37m█████\\e[0m"
    echo -e "\e[0m\e[1;30m█████\\e[0m\e[1;31m█████\\e[0m\e[1;32m█████\\e[0m\e[1;33m█████\\e[0m\e[1;34m█████\\e[0m\e[1;35m█████\\e[0m\e[1;36m█████\\e[0m\e[1;37m█████\\e[0m"
    echo ""
}

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_PATH="$(dirname "$SCRIPT_PATH")"

if [ -e $PARENT_PATH"/apply-colors.sh" ]; then
    gogh_colors
    source $PARENT_PATH"/apply-colors.sh"
else
    gogh_colors
    source <(wget  -O - https://raw.githubusercontent.com/Mayccoll/Gogh/master/apply-colors.sh)
fi
