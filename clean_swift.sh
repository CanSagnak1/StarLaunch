#!/bin/bash

# Script to clean Swift files:
# - Keep first 7 lines (header comments)
# - Remove single-line comments (//)
# - Remove print statements
# - Remove empty lines that result from removal

find /Users/cansagnak/Desktop/StarLaunch/StarLaunch -name "*.swift" | while read file; do
    echo "Cleaning: $file"
    
    # Create temp file
    temp_file=$(mktemp)
    
    # Process file
    awk '
    NR <= 7 { print; next }  # Keep first 7 lines as-is
    /^[[:space:]]*\/\// { next }  # Skip single-line comments
    /^[[:space:]]*print\(/ { next }  # Skip print statements
    /[[:space:]]print\(.*\)[[:space:]]*$/ { next }  # Skip inline print statements
    { print }
    ' "$file" > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
done

echo "Done cleaning Swift files!"
