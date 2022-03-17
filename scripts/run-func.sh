#!/usr/bin/env bash
# 参考: 

set -Eeu

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
source "${LibDir}/loader.sh"

"$@"
