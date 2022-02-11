CheckFunctionDefined(){
    typeset -f "${1}" 1> /dev/null
}

PrintArray(){
    (( $# >= 1 )) || return 0
    printf "%s\n" "${@}"
}

GetBaseName(){
    xargs -L 1 basename
}

ShowVariable(){
    [[ ! -v "$1" ]] && {
        MsgDebug "$1 is undefined"
        return 0
    }
    MsgDebug "${1}=$(eval "echo \"\${${1}}\"")"
}

UserCheck(){
    cut -d ":" -f 1 < "/etc/passwd" | grep -qx "$1"
}


PrintOneLineCSV(){
    tr "," "\n" <<< "$1" | grep -Ev "^$"
}

# MakeSymLink <Real file path> <Link path>
MakeSymLink(){
    [[ -e "$2" ]] && {
        rm -rf "$2"
    }

    MakeDir "$(dirname "$2")"
    ln -s "$1" "$2"
}

MakeDir(){
    MsgDebug "Create dir: $*"
    #sudo mkdir -p "$@"
    mkdir -p "$@"
}

# GetLastSplitString <delim> <string>
GetLastSplitString(){
    rev <<< "$2" | cut -d "$1" -f 1 | rev
}

# CutLastString <Full String> <Last String>
CutLastString(){
    echo "${1%%"${2}"}"
}

GetLine(){
    head -n "$1" | tail -n 1
}

CheckCommand(){
    type "$1" 2> /dev/null 1>&2 || {
        MsgError "Missing command: ${1}"
        return 1
    }
}

# PrintArray <array> | ForArray <command>
ForArray(){
    local _Item _Cmd _C
    while read -r _Item; do
        for _C in "$@"; do
            #shellcheck disable=SC2001
            _Cmd+=("$(sed "s|{}|${_Item}|g" <<< "$_C")")
        done
        "${_Cmd[@]}" || return 1
        _Cmd=()
    done
}
