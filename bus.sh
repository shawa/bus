#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


readonly URL="https://dublinked.ie/cgi-bin/rtpi/realtimebusinformation"
readonly STOP="$1"

curl -s "$URL?stopid=$STOP" \
    | jq -r '.results[]|"\(.route),\(.destination),\(.duetime)"' \
    | column -ts,
