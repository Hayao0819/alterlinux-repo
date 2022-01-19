#!/usr/bin/env bash
set -Eeu

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
DockerName="alterlinux-repo-build"
DOCKER_RUN_OPT=()
DOCKER_BUILD_OPT=()
Main_OPT=()


#-- Functions --#
DockerMountDir(){
    DOCKER_RUN_OPT+=(-v "${1}:${2}")
}


#-- Configure --#
# Do not edit path
DockerMountDir "${OutDir}" "/Repo/"
DockerMountDir "$CurrentDir" "/Main"

# 
DOCKER_BUILD_OPT+=(-t "$DockerName:latest" "${CurrentDir}")
DOCKER_RUN_OPT+=(--rm --privileged "$DockerName:latest")

#-- Run --#
docker build "${DOCKER_BUILD_OPT[@]}" 
exec docker run "${DOCKER_RUN_OPT[@]}" "${Main_OPT[@]}" "${@}"

