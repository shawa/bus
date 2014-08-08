#!/bin/sh

readonly API_URL='http://www.dublinked.ie/cgi-bin/rtpi'
readonly CREDENTIALS=''
readonly STOPS_CACHE='stops.json'

function usage {
    cat <<EOF
Unofficial BS-free transit information for Dublin Bus, LUAS and Iarnród Éireann

usage:
    $0 <stop id> [route id]
        Fetch RTPI information for <stop id>

    $0 <action> [args]

actions:
    search <query> [-g]
        List all stop ids whose name contains query, if -g is set, search in Gaeilge.

    info <stop id>
        Fetch and display detailed information regarding stop <stop_id>.

    route <route id> [db|be|ir|luas]
        List all stops serving <route id>. Where operators share a route number,
        narrow search. bac: Dublin Bus, BE: Bus Éireann, IR: Iarnród Éireann, LUAS: LUAS

Data is provided by http://dublinked.com/datastore/datasets/dataset-300.php,
used under PSI General Licence http://psi.gov.ie/files/2010/03/PSI-Licence.pdf
EOF
}

function tabulate {
    awk -F ':' 'BEGIN {OFS=":";}{print  "\033[1;34m"$1"\033[0m",$2,$3}' \
    | column -t -s ':' \
    | column
}

function rtpi_query {
    local stop_id="$1"
    local route_id="$2"
    local quiet_mode=""

    curl -su "$CREDENTIALS" "$API_URL/realtimebusinformation?stopid=$stop_id&routeid=$route_id" \
        | jq -r '
                if (.errorcode == "0") then (
                    .results[]
                        | "\(.route):\(.destination):\(if .duetime=="Due" then "Due" else "\(.duetime)" end)"
                ) else
                    .errormessage
                end
                '
}


function name_query {
    local stop_id="$1"

    jq -r --arg STOPID "$stop_id" --arg MODE "$mode"\
        '.results
        | map(select(.stopid==$STOPID))[]
        | "\(.fullname):\(.shortname):\(.operators[].name):\(.operators[].routes):\(.latitude):\(.longitude)"
        ' \
        < $STOPS_CACHE \
        | tr -d '"'
}


function search {
    local querystring="$1"
    local lang="$2"

    jq  -r --arg QUERY "$querystring" --arg LANG "$lang"\
        '.results
        | map(select( if $LANG!="ga" then
                        ( (.fullname | contains($QUERY)) or (.shortname | contains($QUERY)))
                       else
                        ( (.fullnamelocalized | contains($QUERY)) or (.shortnamelocalized | contains($QUERY)) )
                        end
                     ))[]
        | "\(.stopid):\(.operators[].name):\(if $LANG!="ga" then "\(if .shortname | length > 0 then "\(.shortname), " else "" end)\(.fullname)" else "\(.fullnamelocalized), \(.shortnamelocalized)" end):\(.latitude),\(.longitude)"
        ' < $STOPS_CACHE \
        | sort -t ':' -k 2\
        | sed 's/bac/db/g; s/BE/be/g; s/LUAS/lu/g' \
        | tabulate

}


function route {
    local route_id=$1
    local operator=""

    [ "$2" = "" ] && operator="bac"
    [ "$2" = "db" ] && operator="bac"
    [ "$2" = "be" ] && operator="BE"
    [ "$2" = "ir" ] && operator="ir"
    [ "$2" = "lu" ] && operator="LUAS"

    printf "Fetching..."
    data="$(curl -su "$CREDENTIALS" "$API_URL/routeinformation?routeid=$route_id&operator=$operator")"
    printf "\r"
    echo "$data" \
    | jq -r '.results[] | "\(.origin) to \(.destination)"'

    read -p "Which route? (1|2|3...): " choix
    echo "$data" \
    | jq -r --arg CHOIX "$choix" \
        '.results[($CHOIX | tonumber) - 1].stops[]
        | "\(.stopid):\(.fullname):\(.shortname)"' \
        | tabulate
}


function info {
    local stop_id="$1"

    name_query "$stop_id" \
    | sed 's/,/, /g'\
    | awk -F ':' '{
                    operators["BE"]   = "Bus Éireann";
                    operators["LUAS"] = "LUAS";
                    operators["bac"]  = "Dublin Bus";
                    operators["ir"]   = "Iarnród Éireann";

                    printf "%s %s\n%s serving routes %s\nhttp://osm.org/?mlat=%s&mlon=%s#map=17/%s/%s\n",
                            $1, $2, operators[$3], $4, $5, $6, $5, $6
                  }'

}


function rtpi {
    local stop_id="$1"
    local route_id="$2"

    local stop_name="$(name_query "$stop_id" | awk -F ':' '{print $1}')"

    rtpi_query "$stop_id" "$route_id" \
    | awk -F ':' '{
                    printf "%-5s%-20s%5s\n",
                    $1, $2, ($3 == "Due")? "Due" : $3"min"
                    }'

    printf "%-19sTime:%6s\n" "$stop_name" "$(date '+%H:%M')"
}

function main {
    [ "$1" = "search" ] && (shift; search $*)
    [ "$1" = "route"  ] && (shift; route  $*)
    [ "$1" = "info"   ] && (shift; info   $*)
    [ "$(jq "[.results[].stopid == \"$1\"] | any" < "$STOPS_CACHE")" = "true" ] && (rtpi $1)
    exit 0;
}

[ ! -f "$STOPS_CACHE" ] && curl -su "$CREDENTIALS" "$API_URL/busstopinformation" > "$STOPS_CACHE"
main $*
