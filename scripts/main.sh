#!/usr/bin/env bash

set -Eeu

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
LibDir="$CurrentDir/lib"
MainDir="$CurrentDir/../"
ReposDir="$CurrentDir/../repos"
source "${LibDir}/loader.sh"

#-- Debug Message --#
ShowVariable ALTER_WORK_DIR
ShowVariable ALTER_OUT_DIR

#-- Function --#
Main(){
    local _repo
    while read -r _repo; do
        MsgDebug "Found repository: $_repo"
        RunBuildAllPkg "${ReposDir}/${_repo}"
    done < <(GetRepoList)
}

#-- Run --#
Main
