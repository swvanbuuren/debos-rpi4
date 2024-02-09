#!/bin/bash

DEBUG=false
ROUTER_IP=""
SERVER_IP=""
SERVER_NAME=""
ALLOW_HOSTS="192.168.0."
declare -A CLIENTS # associative array (hash table)
declare -A WINDOWS_CLIENTS # associative array (hash table)
declare -a MOUNT_POINTS # array

check_named() {
    if [[ "$1" =~ ^[^=]+=.*$ ]]; then
        return 0  # valid
    else
        echo "Invalid --named_option format: $1. Use --option name=value."; exit 1;
    fi
}

check_unnamed() {
    if [[ -n "$1" && ! "$1" =~ ^-.*$ ]]; then
        return 0  # valid
    else
        echo "Invalid --unnamed_option format. Use --option value."; exit 1;
    fi
}

# Function to parse and process the input arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --client)
                check_named "$2" && CLIENTS["${2%%=*}"]="${2#*=}"; shift 2 ;;
            --windows-client)
                check_named "$2" && WINDOWS_CLIENTS["${2%%=*}"]="${2#*=}"; shift 2 ;;
            --mount_point)
                check_unnamed "$2" && MOUNT_POINTS+=("$2     "); shift 2 ;;
            --router_ip)
                check_unnamed "$2" && ROUTER_IP="$2"; shift 2 ;;
            --server_ip)
                check_unnamed "$2" && SERVER_IP="$2"; shift 2 ;;
            --server_name)
                check_unnamed "$2" && SERVER_NAME="$2"; shift 2 ;;
            --allow_hosts)
                check_unnamed "$2" && ALLOW_HOSTS="$2"; shift 2 ;;
            --debug)
                DEBUG=true; shift 1 ;;
            *)
                echo "Unknown option: $1"; exit 1 ;;
        esac
    done
}

# Example usage
parse_arguments "$@"

if [ $DEBUG = true ]; then
    echo "ROUTER_IP=${ROUTER_IP}"
    echo "SERVER_IP=${SERVER_IP}"
    echo "SERVER_NAME=${SERVER_NAME}"
    echo "CLIENTS:"
    for key in "${!CLIENTS[@]}"; do echo "  $key: ${CLIENTS[$key]}"; done
    echo "WINDOWS_CLIENTS:"
    for key in "${!WINDOWS_CLIENTS[@]}"; do echo "  $key: ${WINDOWS_CLIENTS[$key]}"; done
    echo "MOUNT_POINTS:";
    for value in "${MOUNT_POINTS[@]}"; do echo "  $value"; done
    exit 1
fi

# Append to /etc/hosts
echo "${ROUTER_IP}    router" >> /etc/hosts
echo "${SERVER_IP}    ${SERVER_NAME}" >> /etc/hosts
export_string=""
for name in "${!CLIENTS[@]}"; do
    ip="${CLIENTS[$name]}"
    echo "$ip     $name" >> /etc/hosts
    export_string="$export_string $name(rw,sync,no_subtree_check,no_root_squash)"
done

for name in "${!WINDOWS_CLIENTS[@]}"; do
    ip="${WINDOWS_CLIENTS[$name]}"
    echo "$ip     $name" >> /etc/hosts
    export_string="$export_string $name(rw,async,no_subtree_check,anonuid=0,anongid=0)"
done

echo "Appending /etc/exports"
file="/etc/exports"
for mount_point in "${MOUNT_POINTS[@]}"; do
    echo "$mount_point$export_string" >> "$file"
    # construct export string
	str_export=$mount_point$export_string
    if ! grep -q "$str_export" "$file"; then
	    echo "$str_export" >> "$file"
    fi
done

cat > /etc/hosts.allow << EOL
portmap: ${ALLOW_HOSTS}
lockd: ${ALLOW_HOSTS}
mountd: ${ALLOW_HOSTS}
rquotad: ${ALLOW_HOSTS}
statd: ${ALLOW_HOSTS}
EOL

cat > /etc/hosts.deny << EOL
portmap: ALL
lockd: ALL
mountd: ALL
rquotad: ALL
statd: ALL
EOL

echo "Appending /etc/default/nfs-kernel-server"
file="/etc/default/nfs-kernel-server"
add_string="RPCMOUNTDOPTS=\"-p 13025\""
comment_string="RPCMOUNTDOPTS=\"--manage-gids\""
replace_string="#$comment_string"
if ! grep -q "$replace_string" "$file"; then
    if ! grep -q "$add_string" "$file"; then
	    replace_string="$replace_string\n$add_string"
    fi
    sed -i -e "s/$comment_string/$replace_string/g" "$file"
fi
