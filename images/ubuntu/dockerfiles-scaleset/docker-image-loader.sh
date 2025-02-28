#!/bin/bash

# Script to load Docker images from a directory with timing information
IMAGE_DIR="/cache"

echo "Starting Docker image loading"

# Check if directory exists
if [ ! -d "$IMAGE_DIR" ]; then
    echo "Error - Directory $IMAGE_DIR not found"
    exit 1
fi

# Start timing the entire operation
start_total=$(date +%s)
success=0
failed=0

# Process each file
for file in "$IMAGE_DIR"/*; do
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    echo "Loading image: $filename"
    
    # Time the individual image load
    start_time=$(date +%s)
    
    if docker image load -i "$file"; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        ((success++))
        echo "Loaded $filename in ${duration}s"
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        ((failed++))
        echo "Failed loading $filename (${duration}s)"
    fi
done

# Calculate total time
end_total=$(date +%s)
total_duration=$((end_total - start_total))

# Print summary
echo "Completed in ${total_duration}s (Success: $success, Failed: $failed)"

exit 0
