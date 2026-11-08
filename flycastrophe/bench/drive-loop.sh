#!/bin/sh
# drive-loop.sh <rapad> <port> <script> : replay an input script forever.
# Script lines: "<TOKEN> <HOLD_MS>" (TOKEN may be a chord, e.g. RT+LEFT),
# "sleep <seconds>", blank lines and "#" comments.
rapad="$1"; port="$2"; script="$3"
while :; do
  while read -r tok arg; do
    case "$tok" in
      ''|'#'*) ;;
      sleep) sleep "$arg" ;;
      *) "$rapad" "$port" --gap 0 --hold "$arg" "$tok" ;;
    esac
  done < "$script"
done
