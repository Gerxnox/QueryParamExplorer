#!/bin/bash

# Take input from the user for target domains
read -p "Enter one or more target domains (space-separated): " -a DOMAINS

# Fetch URLs from Wayback Machine using waybackurls
for domain in "${DOMAINS[@]}"; do
    waybackurls "$domain" >> wayback_urls.txt
done

# Apply initial filtering
cat wayback_urls.txt | grep "?" > filtered_urls.txt

# Define patterns to exclude using grep
EXCLUDE_PATTERNS="\/page\/[0-9]+\/|\/posts\/|\/page.php\?id=[0-9]+|\.jpg|\.png|\.js|\.css"

# Apply additional filtering
cat filtered_urls.txt | grep -vE "$EXCLUDE_PATTERNS" > final_urls.txt

# Crawl parameters for each URL
while read -r url; do
    # Fetch the webpage content using curl
    content=$(curl -s "$url")
    
    # Extract URLs with query parameters using grep
    echo "$content" | grep -Eo 'https?://[^/"]+\?[^"]+' >> crawled_params.txt
done < final_urls.txt

echo "URLs with parameters have been crawled and saved to crawled_params.txt"
