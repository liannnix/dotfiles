ssh() {
  # grep -w: match command names such as "tmux-2.1" or "tmux: server"
  if ps -p $$ -o ppid= \
    | xargs -i ps -p {} -o comm= \
    | grep -qw tmux; then
    # Note: Options without parameter were hardcoded,
    # in order to distinguish an option's parameter from the destination.
    #
    #                   s/[[:space:]]*\(\( | spaces before options
    #     \(-[46AaCfGgKkMNnqsTtVvXxYy]\)\| | option without parameter
    #                     \(-[^[:space:]]* | option
    # \([[:space:]]\+[^[:space:]]*\)\?\)\) | parameter
    #                      [[:space:]]*\)* | spaces between options
    #                        [[:space:]]\+ | spaces before destination
    #                \([^-][^[:space:]]*\) | destination
    #                                   .* | command
    #                                 /\6/ | replace with destination
    ssh_user=
    ssh_host=
    ssh_user_host=
    out="$(echo "$@" \
      | sed -E 's/[[:space:]]*(((-[46AaCfGgKkMNnqsTtVvXxYy])|(-[^[:space:]]*([[:space:]]+[^[:space:]]*)?))[[:space:]]*)*[[:space:]]+([^-][^[:space:]]*).*/\6/')"
    if grep -o '@' >/dev/null 2>&1 <<< $out; then
        ssh_host="$(sed -E '/@/!d; s/^.*@//g' <<< $out)"
        ssh_user="$(sed -E '/@/!d; s/@[^@]*$//g' <<< $out)"
    else
        ssh_host="$out"
    fi
    [ -n "$ssh_user" ] &&
        ssh_user_host="$ssh_user@$ssh_host" ||
        ssh_user_host="$ssh_host"
    tmux select-pane -T "$ssh_user_host"
    command ssh "$@"
    local_host="$(hostnamectl hostname)"
    local_user="$(id -un)"
    tmux select-pane -T "$local_user@$local_host"
    #tmux set-window-option automatic-rename "on" 1> /dev/null
  else
    command ssh "$@"
  fi
}
