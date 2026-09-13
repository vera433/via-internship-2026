#!/usr/bin/env bash
# ------------------------------------------------------------
# @title       Task3_pipes_redirection.sh
# @author      Vera Baiden
# @index       7354523
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Generates sample log data, then uses pipes and text
#              tools to summarize it (counts, top IPs, error lines).
# @date        2026-09-13
# ------------------------------------------------------------

usage() {
  echo "Usage: $0"
  exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
fi

log_file="sample.log"
results_file="results.txt"
errors_file="errors.log"

# STEP 1: Generate sample log data using a heredoc, write it to a file.
cat > "$log_file" << 'EOF'
2026-09-11 10:00:00 INFO 192.168.1.10 User login successful
2026-09-11 10:00:05 INFO 192.168.1.11 User login successful
2026-09-11 10:00:10 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:20 INFO 192.168.1.10 User login successful
2026-09-11 10:00:25 INFO 192.168.1.12 User login successful
2026-09-11 10:00:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:35 INFO 192.168.1.10 User login successful
2026-09-11 10:00:40 WARN 192.168.1.11 Disk usage above 80%
2026-09-11 10:00:45 INFO 192.168.1.13 User login successful
2026-09-11 10:00:50 ERROR 192.168.1.10 Connection timeout
2026-09-11 10:00:55 INFO 192.168.1.10 User login successful
2026-09-11 10:01:00 INFO 192.168.1.14 User login successful
2026-09-11 10:01:05 WARN 192.168.1.23 Disk usage above 80%
2026-09-11 10:01:10 INFO 192.168.1.10 User login successful
2026-09-11 10:01:15 ERROR 192.168.1.11 Connection timeout
2026-09-11 10:01:20 INFO 192.168.1.10 User login successful
2026-09-11 10:01:25 INFO 192.168.1.15 User login successful
2026-09-11 10:01:30 INFO 192.168.1.10 User login successful
2026-09-11 10:01:35 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:01:40 INFO 192.168.1.16 User login successful
2026-09-11 10:01:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:50 INFO 192.168.1.10 User login successful
2026-09-11 10:01:55 INFO 192.168.1.17 User login successful
2026-09-11 10:02:00 WARN 192.168.1.11 Disk usage above 80%
2026-09-11 10:02:05 INFO 192.168.1.10 User login successful
2026-09-11 10:02:10 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:02:15 INFO 192.168.1.18 User login successful
2026-09-11 10:02:20 INFO 192.168.1.10 User login successful
2026-09-11 10:02:25 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:02:30 INFO 192.168.1.19 User login successful
2026-09-11 10:02:35 ERROR 192.168.1.11 Connection timeout
2026-09-11 10:02:40 INFO 192.168.1.10 User login successful
2026-09-11 10:02:45 INFO 192.168.1.20 User login successful
2026-09-11 10:02:50 WARN 192.168.1.23 Disk usage above 80%
2026-09-11 10:02:55 INFO 192.168.1.10 User login successful
2026-09-11 10:03:00 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:03:05 INFO 192.168.1.10 User login successful
2026-09-11 10:03:10 INFO 192.168.1.21 User login successful
2026-09-11 10:03:15 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:03:20 INFO 192.168.1.10 User login successful
2026-09-11 10:03:25 ERROR 192.168.1.11 Connection timeout
2026-09-11 10:03:30 INFO 192.168.1.22 User login successful
2026-09-11 10:03:35 INFO 192.168.1.10 User login successful
2026-09-11 10:03:40 WARN 192.168.1.23 Disk usage above 80%
2026-09-11 10:03:45 INFO 192.168.1.10 User login successful
2026-09-11 10:03:50 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:03:55 INFO 192.168.1.24 User login successful
2026-09-11 10:04:00 INFO 192.168.1.10 User login successful
2026-09-11 10:04:05 WARN 192.168.1.11 Disk usage above 80%
2026-09-11 10:04:10 INFO 192.168.1.10 User login successful
2026-09-11 10:04:15 ERROR 192.168.1.23 Connection timeout
EOF

echo "Success: generated sample log data at $log_file."

# STEP 2: Compute the total number of log lines.
total_lines=$(wc -l < "$log_file")

# STEP 3: Count of lines per log level (INFO/WARN/ERROR).
level_counts=$(awk '{print $3}' "$log_file" | sort | uniq -c)

# STEP 4: Top 3 most frequent IP addresses.
top_ips=$(awk '{print $4}' "$log_file" | sort | uniq -c | sort -rn | head -3)

# STEP 5: All ERROR lines only.
error_lines=$(grep "ERROR" "$log_file")

# STEP 6: Write the summary report to results.txt (redirecting output).
{
  echo "----- Log Summary Report -----"
  echo "Total log lines: $total_lines"
  echo ""
  echo "Lines per log level:"
  echo "$level_counts"
  echo ""
  echo "Top 3 most frequent IP addresses:"
  echo "$top_ips"
  echo ""
  echo "All ERROR lines:"
  echo "$error_lines"
} > "$results_file"

echo "Success: summary report written to $results_file."

# STEP 7: Demonstrate stderr redirection - run a command that will fail
# (grep for a pattern in a file that doesn't exist) and send its error
# message to errors.log instead of letting it print to the terminal.
grep "ERROR" nonexistent_file.log 2> "$errors_file"

if [ -s "$errors_file" ]; then
  echo "Success: an error occurred and was redirected to $errors_file (as expected)."
else
  echo "No errors were captured in $errors_file."
fi

exit 0
