#!/bin/sh

# ##################################################################################
# Copyright (C) 2025 Altera Corporation
#
# This software and the related documents are Altera copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this software
# or the related documents without Altera's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.
# ##################################################################################

# Default values
ITERATIONS=0
BOARD=""
PRIORITY=90
MAX_US_SCALE=400
LOOPS=100000000
INTERVAL=200
CORE=1

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --iterations)
      ITERATIONS="$2"
      shift 2
      ;;
    --board)
      BOARD="$2"
      shift 2
      ;;
    --priority)
      PRIORITY="$2"
      shift 2
      ;;
    --max_us_scale)
      MAX_US_SCALE="$2"
      shift 2
      ;;
    --loops)
      LOOPS="$2"
      shift 2
      ;;
    --interval)
      INTERVAL="$2"
      shift 2
      ;;
    --core)
      CORE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --iterations <num> [--board <name>] [--priority <num>] [--max_us_scale <num>] [--loops <num>] [--interval <num>] [--core <num>]"
      exit 1
      ;;
  esac
done

# Validate iterations
if [ "$ITERATIONS" -le 0 ]; then
  echo "Error: You must specify a positive number with --iterations"
  exit 1
fi

# Run the test
for i in $(seq 1 "$ITERATIONS"); do
  FILENAME="output_hack"
  [ -n "$BOARD" ] && FILENAME="${FILENAME}_board${BOARD}"
  FILENAME="${FILENAME}_it${i}_prio${PRIORITY}_max${MAX_US_SCALE}_loops${LOOPS}_intv${INTERVAL}_core${CORE}"

  CMD="cyclictest -l${LOOPS} -m -p${PRIORITY} -i${INTERVAL} -h${MAX_US_SCALE} -a${CORE} -q > ${FILENAME}"

  echo ""
  echo "Iteration $i: Executing command:"
  echo "$CMD"
  echo ""

  # Start cyclictest in the background
  eval "$CMD" &
  CYCLICTEST_PID=$!

  pid=$(pidof cyclictest)
  for tid in /proc/$pid/task/*; do
    tid=$(basename $tid)
    cpu=$(awk '{print $39}' /proc/$pid/task/$tid/stat)
    echo "TID $tid → CPU $cpu"
  done

  # Run hackbench in a loop while cyclictest is active, suppressing output
  while kill -0 $CYCLICTEST_PID 2>/dev/null; do
    hackbench -g 20 > /dev/null 2>&1
    # Sleep for a short period to avoid excessive CPU usage
    sleep 1
  done

  # Wait for cyclictest to finish
  wait $CYCLICTEST_PID
done

echo ""
echo "All $ITERATIONS iterations completed."
