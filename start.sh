#!/usr/bin/env bash
set -Eeuxv

#-- Help document --#
HelpDoc(){
    echo "usage: start.sh [command] [args]"
}

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
LibDir="$CurrentDir/scripts/lib"
MainDir="$CurrentDir/"
ReposDir="$CurrentDir/repos"
source "${LibDir}/loader.sh"


#-- Configs --#
OutDir="${HOME}/repo/"
WorkDir="$CurrentDir/work"
GPGKey=""
DockerName="alterlinux-repo-build"
DOCKER_RUN_OPT=()
DOCKER_BUILD_OPT=()
Main_OPT=()


#-- Functions --#
HelpDoc(){
    echo "usage: start.sh [option]"
    echo
    echo " General options:"
    echo "    -h | --help              This help message"
}
DockerMountDir(){
    DOCKER_RUN_OPT+=(-v "${1}:${2}")
}

#-- Parse command-line options --#
# Parse options
ParseCmdOpt SHORT="g:h" LONG="gpg:,help" -- "${@}" || exit 1
eval set -- "${OPTRET[@]}"
unset OPTRET

while true; do
    case "${1}" in
        -g | --gpg)
            GPGKey="$2"
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


#-- Configure --#
# Do not edit path
DockerMountDir "${OutDir}" "/Repo/"
DockerMountDir "$WorkDir" "/Work"
#DockerMountDir "$CurrentDir" "/Main"
if [[ -n "${GPGKey-""}" ]]; then
    DockerMountDir "${HOME}/.gnupg" "/Work/GPG"
    DOCKER_RUN_OPT+=("--env" "ALTER_SIGN_KEY=$GPGKey" "--env" "ALTER_GPG_DIR=/Work/GPG")
fi


# 
DOCKER_BUILD_OPT+=(-t "$DockerName:latest" "${CurrentDir}")
DOCKER_RUN_OPT+=(--rm --privileged=true -it "$DockerName:latest")

#-- Run --#
docker build "${DOCKER_BUILD_OPT[@]}" 
exec docker run "${DOCKER_RUN_OPT[@]}" "${Main_OPT[@]}" "${@}"

