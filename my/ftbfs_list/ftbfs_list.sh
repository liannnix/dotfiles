#!/usr/bin/bash

tmp=$(mktemp -d)

# Clean up temporary directory on exit
trap 'rm -rf "$tmp"' EXIT

curl https://git.altlinux.org/beehive/stats/Sisyphus-x86_64/ftbfs-joined >"$tmp/ftbfs-joined"

# Extract and format the data into a table
format_table() {
    awk -F'\t' 'BEGIN {
        print "┌──────────────────────────────────────┬──────────────────────────────────────┬───────┬────────────────────────────────────────┐"
        print "│ Package                              │ Version                              │ Weeks │ ACL                                    │"
        print "├──────────────────────────────────────┼──────────────────────────────────────┼───────┼────────────────────────────────────────┤"
    }
    {
        printf "│ %-36s │ %-36s │ %-5s │ %-38s │\n", $1, $2, $3, $4
    }
    END {
        print "└──────────────────────────────────────┴──────────────────────────────────────┴───────┴────────────────────────────────────────┘"
    }'
}

format_table <"$tmp/ftbfs-joined"
