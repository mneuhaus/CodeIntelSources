#!/usr/bin/env bash

DEPLOYING=1
source build.sh

echo "Reset hard to (${GIT_BRANCH:-unknown} branch)..." && \
reset_hard && \
echo "Reset Done!" || \
echo "Reset Failed!"
