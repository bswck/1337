#!/usr/bin/env bash

# "THE BEERWARE LICENSE" (Revision 42):
# Bartosz Sławecki (bswck) wrote this code. As long as you retain this
# notice, you can do whatever you want with this stuff. If we
# meet someday, and you think this stuff is worth it, you can
# buy me a beer in return.

# shellcheck disable=SC2034

set -eEuo pipefail

: "${MKTOPICS_SOURCES_DIR:=./sources}"

MKTOPICS_LEVELS=(
    "easy"
    "medium"
    "hard"
)

mktopic() {
    local d dl lv lvs kf="${MKTOPICS_KEEPFILE:=.gitkeep}"
    test "$1$2" || (echo "Usage: mktopic <source> <topic> [levels...]" >&2 && return 1)
    d="$1/$(echo "$2" | tr '[:upper:]' '[:lower:]' | tr -d "()" | tr -cs '[:alnum:]\n' '_')"
    shift 2; lvs=("${@:-${MKTOPICS_LEVELS[@]}}"); for lv in "${lvs[@]}"
    do mkdir -p "${dl:=$d/$lv}" \
        && if test "$(git ls-files "$dl" -x "$kf" --exclude-standard --others)"
        then rm -f "$dl/$kf"; else touch "$dl/$kf"; fi; unset dl
    done
    echo "$d"
}

entrypoint() {
    local topic source source_files dest_info source_info vcs_aware=0
    test "${1:-}" = "--vcs-aware" && vcs_aware=1
    readarray -t source_files <<< "$(find "$MKTOPICS_SOURCES_DIR" -type f -name "*.txt")"
    echo -e "\033[0;32m✔\033[0m Found \033[0;34m${#source_files[@]}\033[0m source(s): ${source_files[*]}"
    for source_file in "${source_files[@]}"
    do
        source=$(basename "$source_file" .txt)
        readarray -t topics < "$source_file"
        for topic in "${topics[@]}"
        do
            created_topic=$(mktopic "$source" "$topic")
            [ $vcs_aware -eq 1 ] && git add --intent-to-add "$created_topic"
            dest_info="\033[0;36m→ $created_topic\033[0m"
            source_info="\033[0;34m$source\033[0m"
            echo -e "\033[0;32m✔\033[0m ($source_info) Created topic \"$topic\" $dest_info"
        done
    done
}

onerror() {
    echo -e "\033[0;31m✖\033[0m An error occurred ($0:$1)" >&2
}

trap 'onerror $LINENO' ERR

entrypoint "$@"
