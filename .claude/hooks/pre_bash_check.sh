#!/bin/bash
cmd=$(python3 -c "import sys,json; print(json.load(sys.stdin).get('command',''))")

patterns=(
    'rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*[[:space:]].*/'
    'sudo[[:space:]]'
    'curl[^|]*\|[[:space:]]*sh'
    'wget[^|]*\|[[:space:]]*sh'
    '^[[:space:]]*dd[[:space:]]'
    '\bmkfs\b'
    'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+'
    'chown[[:space:]]+-R'
    ':\(\)\{[[:space:]]*:\|:&'
    'eval[[:space:]]+\$\('
    'base64[^|]*\|[[:space:]]*sh'
)

for pattern in "${patterns[@]}"; do
    if echo "$cmd" | grep -qE "$pattern"; then
        printf 'BLOCKED: dangerous command detected\n' >&2
        exit 2
    fi
done
