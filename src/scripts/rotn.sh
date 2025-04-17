#!/bin/bash

# ============================================================
# rotn - Caesar Cipher Decryption Tool for Any Rotation
# Author     : Mahros
# Version    : 1.0
# License    : MIT
# Description: Decrypts Caesar cipher using a specified rotation.
#              Input can be a file or a direct string. It will be
#              auto-detected.
# ============================================================

# ---------- USAGE FUNCTION ----------
usage() {
    echo "Usage: $0 <input> -s SHIFT"
    echo
    echo "Arguments:"
    echo "  <input>    Cipher input as plain text or a filename"
    echo "  -s SHIFT   Caesar cipher shift (e.g., 13 for ROT13)"
    echo "  -h         Show this help message"
    echo
    echo "Examples:"
    echo "  $0 'Wklv lv d whvw' -s 3"
    echo "  $0 secret.txt -s 5"
    exit 1
}

# ---------- ARGUMENT VALIDATION ----------
if [[ $# -eq 0 ]]; then
    usage
fi

# Extract the positional input (first argument)
input="$1"
shift  # Remaining args are options

# Parse the remaining options
shift_val=""
while getopts ":s:h" opt; do
    case ${opt} in
        s )
            shift_val="${OPTARG}"
            ;;
        h )
            usage
            ;;
        \? )
            echo "Error: Invalid option -$OPTARG" >&2
            usage
            ;;
        : )
            echo "Error: Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check that shift value is provided
if [[ -z "$shift_val" ]]; then
    echo "Error: Shift value (-s) is required." >&2
    usage
fi

# Check if input is a file or a string
if [[ -f "$input" && -r "$input" ]]; then
    input_text=$(<"$input")
else
    input_text="$input"
fi

# ---------- CAESAR DECRYPTION FUNCTION ----------
caesar_decrypt() {
    local text="$1"
    local shift="$2"
    local result=""

    # Normalize shift to [0-25]
    shift=$(( (26 + (shift % 26)) % 26 ))

    for (( i=0; i<${#text}; i++ )); do
        char="${text:$i:1}"
        ascii=$(printf "%d" "'$char")

        # Uppercase A-Z
        if [[ $ascii -ge 65 && $ascii -le 90 ]]; then
            decrypted=$(( (ascii - 65 - shift + 26) % 26 + 65 ))
            result+=$(printf "\\$(printf "%03o" $decrypted)")

        # Lowercase a-z
        elif [[ $ascii -ge 97 && $ascii -le 122 ]]; then
            decrypted=$(( (ascii - 97 - shift + 26) % 26 + 97 ))
            result+=$(printf "\\$(printf "%03o" $decrypted)")

        # Non-alphabetic characters remain unchanged
        else
            result+="$char"
        fi
    done

    echo "$result"
}

# ---------- RUN THE DECRYPTION ----------
output=$(caesar_decrypt "$input_text" "$shift_val")
echo "$output"
