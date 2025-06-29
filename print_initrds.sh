#!/usr/bin/env bash
# Print unique linux/initrd pairs from systemd-boot entries in case I need to delete them manually 
# Directory with systemd-boot loader entries
entries_dir="/boot/loader/entries"

# Ensure it exists
if [ ! -d "$entries_dir" ]; then
  echo "Error: $entries_dir not found."
  exit 1
fi

# Use awk to extract and sort unique linux/initrd pairs
echo "Unique linux/initrd paths in boot entries:"
grep -hE '^\s*(linux|initrd)' "$entries_dir"/*.conf \
  | awk '{ key=$1; $1=""; val=substr($0,2); print key ": " val }' \
  | paste -d ' ' - - \
  | sort -u
