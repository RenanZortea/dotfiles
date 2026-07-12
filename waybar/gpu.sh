#!/usr/bin/env bash
#                    __
#  _    _____ ___ __/ /  ___ _____
# | |/|/ / _ `/ // / _ \/ _ `/ __/
# |__,__/\_,_/\_, /_.__/\_,_/_/
#            /___/
#
# GPU usage for the Waybar hardware group (NVIDIA / nvidia-smi)

# hide-empty-text in the module config hides the bar entry when text is empty,
# so an absent GPU degrades to nothing rather than an error string.
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo '{"text":"","tooltip":"nvidia-smi not found","class":"unavailable"}'
    exit 0
fi

read -r stats < <(nvidia-smi \
    --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name \
    --format=csv,noheader,nounits 2>/dev/null | head -n1)

if [ -z "$stats" ]; then
    echo '{"text":"","tooltip":"GPU unavailable","class":"unavailable"}'
    exit 0
fi

IFS=',' read -r util temp mem_used mem_total name <<<"$stats"

# nvidia-smi pads its CSV fields with spaces
util="${util// /}"
temp="${temp// /}"
mem_used="${mem_used// /}"
mem_total="${mem_total// /}"
name="$(echo "$name" | sed 's/^ *//; s/ *$//')"

vram_pct=0
if [ "$mem_total" -gt 0 ] 2>/dev/null; then
    vram_pct=$((mem_used * 100 / mem_total))
fi

class="good"
if [ "$util" -ge 90 ] 2>/dev/null; then
    class="critical"
elif [ "$util" -ge 70 ] 2>/dev/null; then
    class="warning"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s\\nUtilization: %s%%\\nTemperature: %s°C\\nVRAM: %s / %s MiB (%s%%)"}\n' \
    "$util" "$class" "$name" "$util" "$temp" "$mem_used" "$mem_total" "$vram_pct"
