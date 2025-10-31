#!/bin/bash

readarray -t TARGETS < <(qlist -I gcc | grep "cross-.*/gcc" | grep -Po "cross-\K[^/]*")

for TARGET in "${TARGETS[@]}"; do
    ${TARGET}-emerge --depclean rust
done