#!/usr/bin/env bash

# LoadShellFiles <file1> <file2> ...
LoadShellFiles(){
    local _file
    for _file in "${@}"; do
        if [[ -e "${_file}" ]]; then 
          typeset -f MsgDebug &> /dev/null && MsgDebug "Loaded script: ${_file}"
          source "${_file}"
        else
          typeset -f MsgDebug &> /dev/null && MsgDebug "${_file} was not found"
        fi
    done
}

CheckBashVersion(){
    MsgDebug "Your bash is ${BASH_VERSION}"
}

WorkInProgress(){
  MsgError "I'm sorry this feature is work in progress."
  return 1
}

: "${ShowDebugMsg=true}"

#-- Start --#

# Load libs
Libraries=(
  "${LibDir}/msg.sh"
  "${LibDir}/readlink.sh"
  "${LibDir}/shellfunc.sh"
  "${LibDir}/parsecmdopt.sh"

  "$LibDir/repos.sh"
  "$LibDir/arch.sh"
  "$LibDir/build.sh"
  "${LibDir}/chroot.sh"
  "${LibDir}/pkgbuild.sh"
)
LoadShellFiles "${Libraries[@]}"

# Show bash version
CheckBashVersion

# ディレクトリパスを正規化
LibDir=$(readlinkf "${LibDir}")
MainDir=$(readlinkf "${MainDir}")
ReposDir=$(readlinkf "$ReposDir")


MsgDebug "Repos is $ReposDir"
