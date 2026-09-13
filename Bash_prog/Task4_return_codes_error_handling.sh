#!/usr/bin/env bash
# ------------------------------------------------------------
# @title       Task4_return_codes_error_handling.sh
# @author      Vera Baiden
# @index       7354523
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Runs a sequence of system checks, using exit codes and
#              a helper function to report pass/fail for each one.
# @date        2026-09-13
# ------------------------------------------------------------
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# ------------------------------------------------------------

usage() {
  echo "Usage: $0 <hostname>"
  exit 1
}

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
fi

host="$1"
required_file="/etc/hostname"
required_command="grep"
temp_file="/tmp/task4_temp.$$"

# Create a temp file to demonstrate cleanup with trap.
echo "temporary data" > "$temp_file"

# Clean up the temp file no matter how the script exits
# (success, failure, or interrupted with Ctrl+C).
cleanup() {
  rm -f "$temp_file"
  echo "Cleanup: removed temporary file."
}
trap cleanup EXIT

# check_status: takes the exit code of the last command, a description,
# and the exit code to use if it failed. Logs pass/fail, exits on failure.
check_status() {
  result="$1"
  description="$2"
  fail_code="$3"

  if [ "$result" -eq 0 ]; then
    echo "PASS: $description"
  else
    echo "FAIL: $description" >&2
    exit "$fail_code"
  fi
}

# CHECK 1: Is the given host reachable?
ping -c 1 -W 2 "$host" > /dev/null 2>&1
check_status "$?" "Host '$host' is reachable" 2

# CHECK 2: Is there enough free disk space? (require at least 10% free)
free_percent=$(df / | tail -1 | awk '{print 100 - $5}' | tr -d '%')
if [ "$free_percent" -ge 10 ]; then
  disk_check_result=0
else
  disk_check_result=1
fi
check_status "$disk_check_result" "At least 10% disk space free" 3

# CHECK 3: Does the required file exist and is it readable?
if [ -r "$required_file" ]; then
  file_check_result=0
else
  file_check_result=1
fi
check_status "$file_check_result" "Required file '$required_file' exists and is readable" 4

# CHECK 4: Is the required command installed?
command -v "$required_command" > /dev/null 2>&1
check_status "$?" "Required command '$required_command' is installed" 5

echo "All checks passed."
exit 0
