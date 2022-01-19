#!/usr/bin/env bash

set -Eeu

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
LibDir="$CurrentDir/../lib"
MainDir="$CurrentDir/../"
ReposDir="$CurrentDir/../repos"
source "${LibDir}/loader.sh"


