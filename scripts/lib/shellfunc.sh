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
    MsgDebug "${1}=$(eval "echo \"\${${1}}\"")"
}

UserCheck(){
    cut -d ":" -f 1 < "/etc/passwd" | grep -qx "$1"
}


PrintOneLineCSV(){
    tr "," "\n" <<< "$1" | grep -Ev "^$"
}
