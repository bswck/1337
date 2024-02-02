#!/usr/bin/env bash

# "THE BEERWARE LICENSE" (Revision 42):
# Bartosz Sławecki (bswck) wrote this code. As long as you retain this
# notice, you can do whatever you want with this stuff. If we
# meet someday, and you think this stuff is worth it, you can
# buy me a beer in return.

# shellcheck disable=SC2034

set -eEuo pipefail

__OK="\033[0;32m✔\033[0m"
__ERR="\033[0;31m✖\033[0m"

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

onerror() {
    echo -e "${__ERR} An error occurred ($0:$1)" >&2
}

trap 'onerror $LINENO' ERR

MKTOPICS_LEVELS=("easy" "medium" "hard")
MKTOPICS_SOURCES=("leetcode")
MKTOPICS_LEETCODE_TOPICS=(
    "Array"
    "String"
    "Hash Table"
    "Dynamic Programming"
    "Math"
    "Sorting"
    "Greedy"
    "Depth-First Search"
    "Binary Search"
    "Database"
    "Breadth-First Search"
    "Tree"
    "Matrix"
    "Two Pointers"
    "Bit Manipulation"
    "Binary Tree"
    "Heap (Priority Queue)"
    "Stack"
    "Prefix Sum"
    "Graph"
    "Simulation"
    "Design"
    "Counting"
    "Sliding Window"
    "Backtracking"
    "Union Find"
    "Linked List"
    "Enumeration"
    "Ordered Set"
    "Monotonic Stack"
    "Number Theory"
    "Trie"
    "Recursion"
    "Divide and Conquer"
    "Bitmask"
    "Queue"
    "Binary Search Tree"
    "Segment Tree"
    "Memoization"
    "Binary Indexed Tree"
    "Geometry"
    "Topological Sort"
    "Combinatorics"
    "Hash Function"
    "Shortest Path"
    "Game Theory"
    "String Matching"
    "Data Stream"
    "Interactive"
    "Rolling Hash"
    "Brainteaser"
    "Monotonic Queue"
    "Randomized"
    "Merge Sort"
    "Iterator"
    "Concurrency"
    "Doubly-Linked List"
    "Probability and Statistics"
    "Quickselect"
    "Bucket Sort"
    "Suffix Array"
    "Minimum Spanning Tree"
    "Counting Sort"
    "Shell"
    "Line Sweep"
    "Reservoir Sampling"
    "Strongly Connected Component"
    "Eulerian Circuit"
    "Radix Sort"
)

entrypoint() {
    local topic source dest_info source_info vcs_aware=0
    test "${1:-}" = "--vcs-aware" && vcs_aware=1
    for source in "${MKTOPICS_SOURCES[@]}"
    do
        declare -n source_ptr
        source_ptr="MKTOPICS_$(echo "$source" | tr '[:lower:]' '[:upper:]')_TOPICS"
        for topic in "${source_ptr[@]}"
        do
            created_topic=$(mktopic "$source" "$topic")
            [ $vcs_aware -eq 1 ] && git add --intent-to-add "$created_topic"
            dest_info="\033[0;36m→ $created_topic\033[0m"
            source_info="\033[0;34m$source\033[0m"
            echo -e "${__OK} ($source_info) Created topic \"$topic\" $dest_info"
        done
    done
}

entrypoint "$@"
