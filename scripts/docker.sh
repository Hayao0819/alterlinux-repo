#!/usr/bin/env bash
# 参考: https://qiita.com/yohm/items/047b2e68d008ebb0f001

set -Eeu

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
ScriptName="$0"
RawArgument=("$@")
LibDir="$CurrentDir/lib"
MainDir="$CurrentDir/../"
ReposDir="$CurrentDir/../repos"
source "${LibDir}/loader.sh"


#-- Functions --#
HelpDoc(){
    echo "usage: docker.sh [Command] [Option]"
    echo
    echo " General options:"
    echo "    -g | --group GID"
    echo "    -u | --user UID"
    echo "    -h | --help              This help message"
}

GROUP_ID="${GROUP_ID-""}"
USER_ID="${USER_ID-""}"

#-- Parse Opts --#
ParseCmdOpt SHORT="g:u:h" LONG="group:,user:,help" -- "${@}" || exit 1
eval set -- "${OPTRET[@]}"
unset OPTRET

while true; do
    case "${1}" in
        -g | --group)
            GROUP_ID="$2"
            shift 2
            ;;
        -u | --user)
            USER_ID="$2"
            shift 2
            ;;
        -h | --help)
            HelpDoc
            exit 0
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
USER="$(whoami)"
usermod -u "$USER_ID" -o -m "$USER"
groupmod -g "$GROUP_ID" "$USER"

"$@"
