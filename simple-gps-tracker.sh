#!/data/data/com.termux/files/usr/bin/bash

# Get current timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Get GPS location via termux-location (JSON output)
if ! command -v termux-location &> /dev/null; then
  echo "termux-location command not found. Please install Termux API package."
  exit 1
fi
if ! command -v jq &> /dev/null; then
  echo "jq command not found. Please install jq package."
  exit 1
fi
if ! command -v curl &> /dev/null; then
  echo "curl command not found. Please install curl package."
  exit 1
fi


# This process might take some time
while true; do
  location_json=$(termux-location -p network -r last)
  if [ -n "$location_json" ]; then
    break
  fi
  echo "Waiting for location..."
  sleep 1
done

# Extract latitude, longitude, accuracy using jq (install via pkg install jq)
latitude=$(echo "$location_json" | jq '.latitude')
longitude=$(echo "$location_json" | jq '.longitude')
accuracy=$(echo "$location_json" | jq '.accuracy')

# Device ID (set per device, e.g., truck-01)
device_id="truck-01"

# Construct JSON payload
payload=$(jq -n \
  --arg ts "$timestamp" \
  --arg dev "$device_id" \
  --argjson lat "$latitude" \
  --argjson lon "$longitude" \
  --argjson acc "$accuracy" \
  '{timestamp: $ts, device_id: $dev, location: {latitude: $lat, longitude: $lon, accuracy: $acc}}')

# Send POST request to server
curl -X POST https://50cb-2a09-bac1-34a0-50-00-3c3-48.ngrok-free.app/v1/track \
  -H "Content-Type: application/json" \
  -d "$payload"
