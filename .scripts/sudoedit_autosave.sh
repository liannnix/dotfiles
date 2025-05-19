#!/usr/bin/bash

abs_filepath() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

su_cat() {
    sudo sh -c 'cat "$1" > "$2"' -- "$1" "$2"
}

file_name="${1##*/}"
file_path="$(abs_filepath "$1")"
extension=$([[ "$file_name" = ?*.* ]] && printf ".%s" "${file_name##*.}" || printf '')
tmp="$(mktemp /var/tmp/"$file_name".XXXXXXXXXXXX"$extension")"

[ -f "$file_path" ] && sudo cat "$file_path" > "$tmp"

(
    while true; do
        # dummy variable to wait for an event
        _=$(inotifywait -q -e create -e moved_to -e close_write "$tmp")
        if [ -f "$tmp" ]; then
            su_cat "$tmp" "$file_path"
        fi
    done
) &

listener_pid=$!

$EDITOR "$tmp"

kill $listener_pid
# wait for the process to finish. Simple `wait` doesn't work here
while $(kill -0 $listener_pid 2>/dev/null); do
    sleep 0\.5
done
su_cat "$tmp" "$file_path"

rm "$tmp"
