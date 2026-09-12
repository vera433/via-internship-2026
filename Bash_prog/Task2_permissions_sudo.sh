#!/usr/bin/env bash
# ------------------------------------------------------------
# @title       Task2_permissions_sudo.sh
# @author      Vera Baiden
# @index       7354523
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Reports a file's permissions, changes them using both
#              numeric and symbolic chmod syntax, and (if run as root)
#              attempts a chown, then reports permissions again.
# @date        2026-09-12
# ------------------------------------------------------------

usage() {
  echo "Usage: $0 <file-path>"
  exit 1
}

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
fi

file="$1"

# Make sure the file actually exists before doing anything else.
if [ ! -f "$file" ]; then
  echo "Error: '$file' does not exist." >&2
  exit 1
fi

# STEP 1: Show current permissions, both symbolic and numeric.
echo "----- Current permissions -----"
ls -l "$file"                      # shows symbolic form, e.g. -rwxr-xr-x
stat -c "%a %n" "$file"            # shows numeric form, e.g. 755 filename

# STEP 2a: Change permissions using numeric syntax.
if chmod 644 "$file"; then
  echo "Success: changed permissions to 644 (numeric syntax)."
else
  echo "Error: could not chmod 644 '$file'." >&2
  exit 1
fi

# STEP 2b: Change permissions using symbolic syntax.
if chmod u+x "$file"; then
  echo "Success: added execute permission for the owner (symbolic syntax: u+x)."
else
  echo "Error: could not chmod u+x '$file'." >&2
  exit 1
fi

# STEP 3: Check if we're running as root, and only attempt chown if so.
if [ "$(id -u)" -eq 0 ]; then
  echo "Running as root — attempting to change file ownership."
  if chown root "$file"; then
    echo "Success: ownership of '$file' changed to root."
  else
    echo "Error: chown failed on '$file'." >&2
  fi
else
  echo "Skipped ownership change: this step needs root privileges (run with sudo to try it)."
fi

# STEP 4: Show permissions again so before/after is visible.
echo "----- Permissions after changes -----"
ls -l "$file"
stat -c "%a %n" "$file"

exit 0
