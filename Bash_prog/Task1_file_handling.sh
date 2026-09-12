#!/usr/bin/env bash
# ------------------------------------------------------------
# @title       Task1_file_handling.sh
# @author      Vera Baiden
# @index       7354523
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Creates a directory and a file inside it, writes to it,
#              reads it, backs it up, then deletes the original safely.
# @date        2026-09-12
# ------------------------------------------------------------

usage() {
  echo "Usage: $0 <target_directory>"
  exit 1
}

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
fi

dir="$1"
file="$dir/demo.txt"

# STEP 1: Create the directory if it doesn't already exist.
if [ -d "$dir" ]; then
  echo "Folder '$dir' already exists."
else
  if mkdir -p "$dir"; then
    echo "Success: folder '$dir' was created."
  else
    echo "Error: could not create folder '$dir'." >&2
    exit 1
  fi
fi

# STEP 2: Write the first line into a new file.
if echo "Hello, this is my first line." > "$file"; then
  echo "Success: wrote to $file."
else
  echo "Error: could not write to $file." >&2
  exit 1
fi

# STEP 3: Append a second line to the same file.
if echo "This is a second, appended line." >> "$file"; then
  echo "Success: appended a line to $file."
else
  echo "Error: could not append to $file." >&2
  exit 1
fi

# STEP 4: Show what's inside the file.
echo "File contents:"
cat "$file"

# STEP 5: Make a backup copy.
if cp "$file" "$file.bak"; then
  echo "Success: backed up to $file.bak"
else
  echo "Error: could not create backup." >&2
  exit 1
fi

# STEP 6: Delete the original, but only after confirming it exists.
if [ -f "$file" ]; then
  echo "Deleting $file now (backup is safe)."
  if rm "$file"; then
    echo "Success: $file was deleted."
  else
    echo "Error: could not delete $file." >&2
    exit 1
  fi
else
  echo "Error: $file does not exist, nothing to delete." >&2
  exit 1
fi

exit 0
