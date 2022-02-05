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
BuildRepo=()
BuildPkg=()
OverRideRepoArch=()
RemoveLockFile=false

#-- Debug Message --#
ShowVariable ALTER_WORK_DIR
ShowVariable ALTER_OUT_DIR
ShowVariable ALTER_SIGN_KEY
MainDir="${ALTER_MAIN_DIR-"${MainDir}"}" OutDir="${ALTER_OUT_DIR-"${MainDir}/out"}"
WorkDir="${ALTER_WORK_DIR-"${MainDir}/work"}"
GPGDir="${ALTER_GPG_DIR-"${HOME}/.gnupg/"}"
GPGKey="${ALTER_SIGN_KEY-""}"
ChrootUser="hayao"

#-- Function --#
HelpDoc(){
    echo "usage: main.sh [option]"
    echo
    echo " General options:"
    echo "    -a | --arch Arch1,Arch2 ..."
    echo "    -g | --gpg KEY"
    echo "    -r | --repo REPO"
    echo "    -p | --pkg PkgBase1,PkgBase2 ..."
    echo "    -w | --work WORK_DIR"
    echo "    -o | --out OUT_DIR"
    echo "    -h | --help              This help message"
    echo "         --rmlock            Remove all lockfile"
    echo "         --gpgdir DIR        Specify GnuPG directory"
}

PrepareBuild(){
    # Add alterlinux-keyring
    if ! pacman -Qq alterlinux-keyring 1> /dev/null 2>&1; then
        sudo pacman-key --init
        curl -Lo - "http://repo.dyama.net/fascode.pub" | sudo pacman-key -a -
        sudo pacman-key --lsign-key development@fascode.net
        sudo pacman --config "$MainDir/configs/pacman-x86_64.conf" -Sy --noconfirm alter-stable/alterlinux-keyring
        sudo pacman-key --populate alterlinux
    fi

    # Setup user
    UserCheck "$ChrootUser" || useradd -m -g root -s /bin/bash "$ChrootUser"
    chmod 775 -R "$ReposDir"

    # Create user
    mkdir -p "$WorkDir/Chroot" "$WorkDir/LockFile"

    # RemoveLockFile
    if [[ "${RemoveLockFile}" = true ]]; then
        rm -rf "$WorkDir/LockFile"
    fi
}

CheckEnvironment(){
    if (( UID == 0 )); then
        MsgError "Do not run as root"
        exit 1
    fi
}

Main(){
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
    readarray -t PkgBuildList < <(
        for _Pkg in "${BuildPkg[@]}"; do
            _PkgBuild="${ReposDir}/${_Repo}/${_Pkg}/PKGBUILD"
            [[ ! -e "${_PkgBuild}" ]] || echo "$_PkgBuild"
        done
    )
    BuildAllArch "$_Repo" "${BuildPkg[@]}"
}

#-- Parse command-line options --#
# Parse options
ParseCmdOpt SHORT="a:g:ho:p:r:w:" LONG="arch:gpg:help,out:,pkg:,repo:,work:,rmlock,gpgdir:" -- "${@}" || exit 1
eval set -- "${OPTRET[@]}"
unset OPTRET

while true; do
    case "${1}" in
        -a | --arch)
            IFS="," read -r -a OverRideRepoArch <<< "${2}"
            shift 2
            ;;
        -g | --gpg)
            GPGKey="$2"
            shift 2
            ;;
        -o | --out)
            OutDir="$2"
            shift 2
            ;;
        -p | --pkg)
            readarray -t BuildPkg < <(PrintOneLineCSV "$2")
            shift 2
            ;;
        -r | --repo)
            readarray -t BuildRepo < <(PrintOneLineCSV "$2")
            shift 2
            ;;
        -w | --work)
            WorkDir="$2"
            shift 2
            ;;
        -h | --help)
            HelpDoc
            exit 0
            ;;
        --rmlock)
            RemoveLockFile=true
            shift 1
            ;;
        --gpgdir)
            GPGDir="$2"
            shift 2
            ;;
        --)
            shift 1
            break
            ;;
        *)
            MsgError "Argument exception error '${1}'"
            MsgError "Please report this error to the developer." 1
            ;;
    esac
done

#-- Run --#
set -xv
export GNUPGHOME="$GPGDir"
CheckEnvironment
PrepareBuild
Main
