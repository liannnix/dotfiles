#!/bin/bash

function generate_tmux_local_pane_name() {
    local local_host="$(hostname -s)"
    local local_user="$(id -un)"
    local local_pwd="$(pwd)"
    local local_homedir="$(getent passwd "$local_user" | cut -d ':' -f 6)"
    local pane_pwd_string="${local_pwd/#$local_homedir/\~}"
    tmux select-pane -T "| $local_user@$local_host | $pane_pwd_string"
}
