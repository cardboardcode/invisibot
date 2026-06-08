#!/usr/bin/env bash

set -e

CONFIG_ROOT="./configs"

# Find valid configuration directories
CONFIG_DIRS=()

while IFS= read -r -d '' dir; do
    if [[ -f "$dir/robots.json" ]]; then
        CONFIG_DIRS+=("$dir")
    fi
done < <(find "$CONFIG_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#CONFIG_DIRS[@]} -eq 0 ]]; then
    echo "No valid configuration folders found in $CONFIG_ROOT"
    exit 1
fi

echo "Available configurations:"
for i in "${!CONFIG_DIRS[@]}"; do
    echo "[$i] $(basename "${CONFIG_DIRS[$i]}")"
done

echo
read -rp "Select configuration index: " SELECTION

if ! [[ "$SELECTION" =~ ^[0-9]+$ ]]; then
    echo "Invalid selection"
    exit 1
fi

if (( SELECTION < 0 || SELECTION >= ${#CONFIG_DIRS[@]} )); then
    echo "Selection out of range"
    exit 1
fi

SELECTED_DIR="${CONFIG_DIRS[$SELECTION]}"
ROBOTS_JSON_FILE="$(realpath "$SELECTED_DIR/robots.json")"

echo
echo "Using configuration: $(basename "$SELECTED_DIR")"
echo "robots.json: $ROBOTS_JSON_FILE"
echo

docker run -it --rm \
    --name invisibot_c \
    -p 8080:8080 \
    -v "$ROBOTS_JSON_FILE:/invisibot_ws/robots.json" \
invisibot:latest bash -c "python3 -m invisibot"