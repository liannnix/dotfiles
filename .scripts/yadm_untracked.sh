#!/usr/bin/bash

files=
uniq_dirs=
uniq_dirs_without_excludes=
home_dir="$HOME"

files="$(yadm list -a | grep '/' )"

uniq_dirs=$(
    for i in $files; do
        dirname "$home_dir/$i"
    done | uniq
)

uniq_dirs_without_excludes=$(
    for i in $uniq_dirs; do
        [ -f "$i/.yadm_ignore_untracked" ] || echo "$i"
    done
)

echo "$uniq_dirs_without_excludes" | xargs yadm status -u
