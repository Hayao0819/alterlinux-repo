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
    sudo mkdir -p "$@"
}
