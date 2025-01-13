#!/bin/bash -e

REPO_ROOT=$(git rev-parse --show-toplevel)
SOURCE_JSON="${REPO_ROOT}/images/ubuntu/toolsets/toolset-2404.json"
TARGET_JSON="${REPO_ROOT}/images.Dev/ubuntu/dockerfiles/persona-frontend/toolset-2404.json"

JQ_FILTER='{
    toolcache: [.toolcache[] | select(.name == "node")],
    apt,
    docker,
    node,
    node_modules,
    php,
    selenium
}'

jq "$JQ_FILTER" "$SOURCE_JSON" > "$TARGET_JSON"
