#!/usr/bin/sh
# shellcheck disable=SC3043
# shellcheck disable=SC2034 # Temporary

## Tasks list
# TODO: list ssh config hosts
# TODO: mount selected host to ~/sshfs/<host>
# TODO: quick mount as user to ~/sshfs/user/<host>
# TODO: autoset idmapping for user mount
# TODO: add autocomplete

## Base vars
script_name="msh"
version="0.1"

## Otions
# default: $1 - host to mount
action="mount"
ssh_hostname="$1"
# .ssh/config path
ssh_config_path="$HOME/.ssh/config"
sshfs_dir="$HOME/sshfs"
sshfs_remote_dir="/"

ssh_config_list_hosts() {
    local ssh_config_path="$1" hosts_list="" ret=1
    hosts_list="$(grep -Ei '^\s*Host\s+[^\*]' "$ssh_config_path" 2>/dev/null | \
        sed -E "s/^[[:space:]]*Host[[:space:]]+([^[:space:]]+)[[:space:]]*.*$/\1/gi" 2>/dev/null)" && ret=0
    [ $ret -eq 0 ] && cat <<< "$hosts_list"
    return $ret
}

## Return:
# 0: host exists
# 1: host not exists
# 2: ssh config file parsing error
ssh_config_check_hostname_exists() {
    local ssh_hostname="$1" ssh_config_path="$2" ret=0
    ssh_config_list_hosts "$ssh_config_path" | \
        grep "$ssh_hostname" >/dev/null 2>&1 || ret=1
    return $ret
}

sshfs_mount() {
    local ssh_hostname="$1" sshfs_dir="$2" sshfs_remote_dir="$3"
    local sshfs_options="-C "
    sshfs_options+="-o reconnect "
    sshfs_options+="-o delay_connect "
    sshfs_options+="-o ServerAliveInterval=15 "
    sshfs_options+="-o workaround=rename:renamexdev "
    sshfs_options+="-o auto_unmount "
    sshfs_options+="-o kernel_cache "
    sshfs_options+="-o max_conns=10 "

    mkdir -p "$sshfs_dir/$ssh_hostname"
    sshfs $sshfs_options "$ssh_hostname:$sshfs_remote_dir" "$sshfs_dir/$ssh_hostname"
}

main() {
    ssh_config_check_hostname_exists "$ssh_hostname" "$ssh_config_path" &&
        sshfs_mount "$ssh_hostname" "$sshfs_dir" "$sshfs_remote_dir"
}

main
