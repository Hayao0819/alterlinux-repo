CheckFunctionDefined(){
    typeset -f "${1}" 1> /dev/null
}

PrintArray(){
    (( $# >= 1 )) || return 0
    printf "%s\n" "${@}"
}

GetFileName(){
    xargs -L 1 basename
}

ShowVariable(){
    MsgDebug "${1}=$(eval "echo \"\${${1}}\"")"
}
