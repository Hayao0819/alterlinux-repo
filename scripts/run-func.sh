#!/usr/bin/env bash
# 参考: 

set -Eeu

#-- Initialize --#
CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
ScriptName="$0"
RawArgument=("$@")
LibDir="$CurrentDir/lib"
MainDir="$CurrentDir/../"
ReposDir="$CurrentDir/../repos"
source "${LibDir}/loader.sh"

#-- Debug Message --#
ShowVariable ALTER_WORK_DIR
ShowVariable ALTER_OUT_DIR
ShowVariable ALTER_SIGN_KEY
MainDir="${ALTER_MAIN_DIR-"${MainDir}"}"
OutDir="${ALTER_OUT_DIR-"${MainDir}/out"}"
WorkDir="${ALTER_WORK_DIR-"${MainDir}/work"}"
GPGDir="${ALTER_GPG_DIR-"${HOME}/.gnupg/"}"
GPGKey="${ALTER_SIGN_KEY-""}"
ChrootUser="hayao"

"$@"
