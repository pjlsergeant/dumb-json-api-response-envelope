#!/bin/sh
# npm install ajv-cli ajv-formats
find examples \
    | grep 'json$' \
    | xargs -n 1 ajv \
        --spec=draft2020 \
        -s schema/v0.0.1.json \
        -c ajv-formats \
        -d