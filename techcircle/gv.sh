#!/bin/bash

# Check if the file containing URLs is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file_with_links>"
    exit 1
fi

# Define the Downloads directory
DOWNLOAD_DIR="$HOME/Downloads"
LOG_FILE="$DOWNLOAD_DIR/download_log.txt"
RETRY_LIMIT=3
FORMAT="mp4"
CLEAR_DELAY=60 # Delay in seconds before clearing the log file if no errors

# Create the Downloads directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Create or clear the log file
: > "$LOG_FILE"

# Function to download a video with retry logic
download_video() {
    local url=$1
    local attempt=1
    local title

    while [ $attempt -le $RETRY_LIMIT ]; do
        echo "[$(date)] Attempting to download video from $url (Attempt $attempt)..." | tee -a "$LOG_FILE"
        
        # Try to get the video title for better log messages
        title=$(yt-dlp --get-title "$url" 2>/dev/null)
        [ -z "$title" ] && title="Unknown Title"
        
        # Download video with specified quality (480p or closest available)
        yt-dlp -f "bestvideo[height<=480]+bestaudio[ext=m4a]/best[height<=480]" --continue -c -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
        
        if [ $? -eq 0 ]; then
            echo "[$(date)] Download successful: $title ($url)" | tee -a "$LOG_FILE"
            return 0
        else
            echo "[$(date)] ERROR: Download failed: $title ($url)" | tee -a "$LOG_FILE"
            attempt=$((attempt+1))
        fi
    done

    echo "[$(date)] ERROR: Failed to download after $RETRY_LIMIT attempts: $title ($url)" | tee -a "$LOG_FILE"
    return 1
}

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "ERROR: yt-dlp is not installed. Please install it and try again." | tee -a "$LOG_FILE"
    exit 1
fi

# Initialize a flag to track if there were any errors
errors=0

# Temporary file to store remaining URLs
TEMP_FILE=$(mktemp)

# Read the file line by line
while IFS= read -r url; do
    if [ ! -z "$url" ]; then
        download_video "$url"
        if [ $? -ne 0 ]; then
            errors=1
            echo "$url" >> "$TEMP_FILE" # Save the failed URL to retry later
        fi
    fi
done < "$1"

# Replace original file with the temporary file if there were failures
if [ $errors -eq 0 ]; then
    echo "[$(date)] All downloads were successful. The log file will be cleared in $CLEAR_DELAY seconds." | tee -a "$LOG_FILE"
    (sleep $CLEAR_DELAY && : > "$LOG_FILE" && echo "[$(date)] Log file cleared." > "$LOG_FILE") &
else
    echo "[$(date)] Downloads completed with errors. Retrying failed downloads..." | tee -a "$LOG_FILE"
    mv "$TEMP_FILE" "$1" # Replace the original file with remaining URLs
fi

# Clean up temporary file
rm -f "$TEMP_FILE"

# If no URLs left, delete the file
[ ! -s "$1" ] && rm -f "$1"

