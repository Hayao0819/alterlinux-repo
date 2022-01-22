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
BuildRepo=()
BuidPkg=()

#-- Debug Message --#
ShowVariable ALTER_WORK_DIR
ShowVariable ALTER_OUT_DIR
MainDir="${ALTER_MAIN_DIR-"${MainDir}"}" OutDir="${ALTER_OUT_DIR-"${MainDir}/out"}"
WorkDir="${ALTER_WORK_DIR-"${MainDir}/work"}"
ChrootUser="hayao"

#-- Function --#
PrepareBuild(){
    # Add alterlinux-keyring
    pacman-key --init
    curl -Lo - "http://repo.dyama.net/fascode.pub" | pacman-key -a -
    pacman-key --lsign-key development@fascode.net
    pacman --config "$MainDir/configs/pacman-x86_64.conf" -Sy --noconfirm alter-stable/alterlinux-keyring
    pacman-key --populate alterlinux

    # Setup user
    UserCheck "$ChrootUser" || useradd -m -g root -s /bin/bash "$ChrootUser"
    chmod 775 -R "$ReposDir"
}

Main(){
    PrepareBuild

    # リポジトリ指定なし
    (( "${#BuildRepo[@]}" < 1 )) && {
        BuildAllPkgInAllRepo
        return 0
    }
    
    # リポジトリ指定ありパッケージ指定なし
    (( "${#BuildPkg[@]}" < 1 )) && {
        local _Repo
        for _Repo in "${BuildRepo[@]}"; do
            BuildAllPkg "$_Repo"
        done
        return 0
    }

    # パッケージ指定あり
    (( ${#BuildRepo[@]} > 1 )) && {
        MsgError "パッケージを指定する場合はリポジトリを２つ以上指定することはできません"
        return 1
    }

    local _Repo="${BuildRepo[*]}"
    BuildAllArch "$_Repo" "${BuildPkg[@]}"
}

#-- Run --#
Main
