#!/bin/bash

# Query NVIDIA GPU utilization
usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

# Output JSON for Waybar
echo "{\"text\": \"$usage%\", \"tooltip\": \"GPU Usage: $usage%\\nTemp: $temp°C\"}"
