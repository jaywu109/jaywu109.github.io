#!/bin/bash

# Image Optimization Script for Personal Website
# This script converts PNG/JPG images to WebP format for better performance
# Usage: ./optimize-images.sh

echo "====================================="
echo "Image Optimization Script"
echo "====================================="
echo ""

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "Error: cwebp is not installed."
    echo "Please install WebP tools:"
    echo ""
    echo "macOS: brew install webp"
    echo "Ubuntu/Debian: sudo apt-get install webp"
    echo "Windows: Download from https://developers.google.com/speed/webp/download"
    echo ""
    exit 1
fi

# Create backup directory
BACKUP_DIR="assets/images/backup-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "Backup directory created: $BACKUP_DIR"
echo ""

# Function to optimize and convert image
optimize_image() {
    local input_file="$1"
    local output_file="${input_file%.*}.webp"
    local filename=$(basename "$input_file")
    
    # Skip if already WebP
    if [[ "$input_file" == *.webp ]]; then
        echo "⏭️  Skipping $filename (already WebP)"
        return
    fi

    # Skip if WebP version already exists
    if [[ -f "$output_file" ]]; then
        echo "⏭️  Skipping $filename (WebP version already exists)"
        return
    fi

    # Copy original to backup before conversion
    cp "$input_file" "$BACKUP_DIR/"

    # Convert to WebP with quality 85 (good balance between quality and size)
    cwebp -q 85 "$input_file" -o "$output_file" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Get file sizes
        original_size=$(du -k "$input_file" | cut -f1)
        new_size=$(du -k "$output_file" | cut -f1)
        savings=$((original_size - new_size))
        savings_percent=$((100 * savings / original_size))
        
        echo "✅ $filename → ${filename%.*}.webp"
        echo "   Original: ${original_size}KB → WebP: ${new_size}KB (Saved: ${savings}KB / ${savings_percent}%)"
        echo ""
    else
        echo "❌ Failed to convert $filename"
        echo ""
    fi
}

# Process publication images
echo "Processing publication images..."
echo "--------------------------------"
shopt -s nullglob
for ext in png jpg jpeg PNG JPG JPEG; do
    for img in assets/images/publications/*."$ext"; do
        [ -e "$img" ] || continue
        optimize_image "$img"
    done
done

# Process profile picture
echo "Processing profile picture..."
echo "--------------------------------"
for ext in png jpg jpeg PNG JPG JPEG; do
    for img in assets/profile-pics/*."$ext"; do
        [ -e "$img" ] || continue
        optimize_image "$img"
    done
done

# Process logo images
echo "Processing logos..."
echo "--------------------------------"
for ext in png jpg jpeg PNG JPG JPEG; do
    for img in assets/images/logos/*."$ext"; do
        [ -e "$img" ] || continue
        optimize_image "$img"
    done
done

echo "====================================="
echo "✨ Optimization Complete!"
echo "====================================="
echo ""
echo "Next steps:"
echo "1. Update _data/publications.yaml to use .webp extensions"
echo "2. Update _data/main_info.yaml profile_pic path to .webp"
echo "3. Test your site locally: bundle exec jekyll serve"
echo "4. If everything works, you can delete the original PNG/JPG files"
echo "5. The backups are in: $BACKUP_DIR"
echo ""

