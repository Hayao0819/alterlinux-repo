#!/usr/bin/env bash
# 参考: 

set -Eeu

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
LibDir="$CurrentDir/lib"
MainDir="$CurrentDir/../"
ReposDir="$CurrentDir/../repos"
source "${LibDir}/loader.sh"

#-- Config --#
BuildArch=("x86_64")

#-- Debug Message --#
ShowVariable ALTER_WORK_DIR
ShowVariable ALTER_OUT_DIR
WorkDir="$ALTER_WORK_DIR" OutDir="$ALTER_OUT_DIR"

#-- Function --#
Main(){
    local _repo _Arch
    while read -r _repo; do
        MsgDebug "Found repository: $_repo"
        for _Arch in "${BuildArch[@]}"; do
            RunBuildAllPkg "${ReposDir}/${_repo}" "$_Arch"
        done
    done < <(GetRepoList)
}

#-- Run --#
Main
