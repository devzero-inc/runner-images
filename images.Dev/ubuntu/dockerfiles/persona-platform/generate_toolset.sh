#!/bin/bash -e

REPO_ROOT=$(git rev-parse --show-toplevel)
SOURCE_JSON="${REPO_ROOT}/images/ubuntu/toolsets/toolset-2404.json"
TARGET_JSON="${REPO_ROOT}/images.Dev/ubuntu/dockerfiles/persona-platform/toolset-2404.json"

JQ_FILTER='{
    toolcache: [.toolcache[] | select(.name == "Python" or .name == "PyPy" or .name == "go" or .name == "node")],
    apt,
    azureModules,
    clang,
    docker,
    gcc,
    pipx,
    pwsh
}'

jq "$JQ_FILTER" "$SOURCE_JSON" > "$TARGET_JSON"
