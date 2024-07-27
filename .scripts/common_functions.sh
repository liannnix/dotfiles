#!/bin/bash

function generate_tmux_local_pane_name() {
    local local_host="$(hostname -s)"
    local local_user="$(id -un)"
    local local_pwd="$(pwd)"
    local local_homedir="$(getent passwd "$local_user" | cut -d ':' -f 6)"
    local pane_pwd_string="${local_pwd/#$local_homedir/\~}"
    local branch="$(git branch --show-current 2>/dev/null)"
    local pane_name="| $local_user@$local_host | $pane_pwd_string"
    local git_modified="$(git status -s -uno 2>/dev/null | wc -l)"
    local git_untracked="$(git status -s 2>/dev/null | grep '??' | wc -l)"
    [ -n "$branch" ] && pane_name="$pane_name | [branch: $branch]"
    [ -n "$git_modified" ] && [ $git_modified -gt 0 ] && pane_name="$pane_name [modif: $git_modified]"
    [ -n "$git_untracked" ] && [ $git_untracked -gt 0 ] && pane_name="$pane_name [untrack: $git_untracked]"
    pane_name="$pane_name |"
    tmux select-pane -T "$pane_name" 2>/dev/null || printf '\033]2;%s\033\\' "$pane_name"
}
