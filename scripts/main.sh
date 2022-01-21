#!/usr/bin/env bash
# 参考: 

set -Eeuxv

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
MainDir="$ALTER_MAIN_DIR" OutDir="$ALTER_OUT_DIR"
WorkDir="$ALTER_WORK_DIR"
ChrootUser="hayao"

#-- Function --#
Main(){
    # Add alterlinux-keyring
    pacman-key --init
    curl -Lo - "http://repo.dyama.net/fascode.pub" | pacman-key -a -
    pacman-key --lsign-key development@fascode.net
    pacman --config "$MainDir/configs/pacman-x86_64.conf" -Sy --noconfirm alter-stable/alterlinux-keyring
    pacman-key --populate alterlinux

    # Setup user
    useradd -m -s /bin/bash "$ChrootUser"

    # Start
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
