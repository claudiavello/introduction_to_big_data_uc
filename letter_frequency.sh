#!/usr/bin/env bash
# letter_frequency.sh
# Author: Claudia Vello
# Course: Introduction to Big Data (UC)
# Date: October 2025


# -e exits immediately on any command error,
# -u treats undefined variables as errors,
# -o pipefail ensures that a failure inside a pipeline propagates
set -euo pipefail

# Help: prints usage instructions and the default file path
usage() {
  echo "Usage: $0 [path/to/textfile.txt]"
  echo "If no file is given, the default is LittleWomen.txt from SWC data."
}

# Help flag
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

# Build download URL in parts to keep lines short
base_url="https://raw.githubusercontent.com"
# Next line is longer than 80 chars but necessary
repo_path="/swcarpentry/shell-novice/f32646f/data"
zip_name="shell-lesson-data.zip"
url="${base_url}${repo_path}/${zip_name}"

# Check that a command exists; else print an error and exit
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: required command '$1' not found." >&2
    exit 1
  }
}

# Ensure required commands are available
for cmd in wget unzip awk sort; do
  need_cmd "$cmd"
done

# Download and unzip only if the data dir is not present
if [[ ! -d "shell-lesson-data" ]]; then
  echo "Downloading dataset..."
  wget -q -O "$zip_name" "$url"
  echo "Unzipping dataset..."
  unzip -q -o "$zip_name"
fi

# Default input file if none provided
default_in="shell-lesson-data/writing/data/LittleWomen.txt"
infile="${1:-$default_in}"

# Validate input file; if missing, print error and exit
if [[ ! -f "$infile" ]]; then
  echo "Error: file not found: $infile" >&2
  exit 1
fi

# Function to compute letter frequencies
letter_freq() {
  # $1 is the input file path
  # Implemented with awk only, to stay close to class content
  # Steps:
  # 1) Convert each line to lowercase with tolower()
  # 2) Split line into chars and count only a..z
  # 3) Compute relative frequency per letter
  # 4) Sort by frequency

  # Stores the file path argument into a local variable f
  local f="$1" 
  awk '
    {
      # Convert each input line to lowercase
      line = tolower($0)
       # Split the line into single characters
      n = split(line, ch, "")
      # Iterate through all characters
      for (i = 1; i <= n; i++) {
        c = ch[i]
        # Count only ASCII letters
        if (c >= "a" && c <= "z") {
          cnt[c]++
          tot++
        }
      }
    }
    END {
      for (i = 97; i <= 122; i++) {
        l = sprintf("%c", i)
        if (tot > 0) {
          printf "%s\t%.6f\n", l, (cnt[l] + 0) / tot
        } else {
          printf "%s\t%.6f\n", l, 0
        }
      }
    }' "$f" \
  | sort -k2,2nr
  # Sort by 2nd column (frequency), numeric, descending
}

# Build output file name in the current directory
# Remove path and extension; add .lfr as required
base="$(basename "$infile")"
name="${base%.*}" 
out="${name}.lfr"

# Progress messages
echo "Computing letter frequencies for: $infile" 
letter_freq "$infile" > "$out" 
echo "Done. Report written to: $(pwd)/$out"
echo "First 10 lines of the report:"
head -n 10 "$out"

# -------------------------------------------------------------
# References
# -------------------------------------------------------------
# Course material:
# - Unix shell introduction by Jesús Fernández
#
# Dataset:
# - Software Carpentry shell-novice data:
#   https://raw.githubusercontent.com/swcarpentry/shell-novice/f32646f/data/shell-lesson-data.zip
#
# Documentation consulted:
# - GNU Bash Manual: https://www.gnu.org/software/bash/manual/
# - GNU Coreutils Manual: https://www.gnu.org/software/coreutils/manual/
# - GNU Awk Manual: https://www.gnu.org/software/gawk/manual/
#
# Online discussions and examples:
# - Stack Overflow thread on sorting numeric columns with sort:
#   https://stackoverflow.com/questions/965053/extract-second-column-from-text-file-and-sort-numerically
# -------------------------------------------------------------