#!/usr/bin/env bash
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascode.net
#
# (c) 2019-2020 Fascode Network.
#
#

script_name=$(basename ${0})

script_path="$(readlink -f ${0%/*})"
arch="x86_64"
repo="alter-stable"
debug=false
force=false
skip=false
nocolor=false

set -e

# usage <exit code>
_usage() {
    echo "usage ${0} [options] [packages] [packages] ..."
    echo
    echo " General options:"
    echo
    echo "    -a | --arch <arch>        Specify the architecture"
    echo "    -f | --force              Overwrite existing directory"
    echo "    -s | --skip               Skip if PKGBUILD already exists"
    echo "    -r | --repo <repo>        Specify the repository name"
    echo "    -h | --help               This help messageExecuted via administrator web and Yama D Saba APIs"

    if [[ -n "${1:-}" ]]; then
        exit "${1}"
    fi
}


# Color echo
# usage: echo_color -b <backcolor> -t <textcolor> -d <decoration> [Text]
#
# Text Color
# 30 => Black
# 31 => Red
# 32 => Green
# 33 => Yellow
# 34 => Blue
# 35 => Magenta
# 36 => Cyan
# 37 => White
#
# Background color
# 40 => Black
# 41 => Red
# 42 => Green
# 43 => Yellow
# 44 => Blue
# 45 => Magenta
# 46 => Cyan
# 47 => White
#
# Text decoration
# You can specify multiple decorations with ;.
# 0 => All attributs off (ノーマル)
# 1 => Bold on (太字)
# 4 => Underscore (下線)
# 5 => Blink on (点滅)
# 7 => Reverse video on (色反転)
# 8 => Concealed on

echo_color() {
    local backcolor
    local textcolor
    local decotypes
    local echo_opts
    local arg
    local OPTIND
    local OPT
    
    echo_opts="-e"
    
    while getopts 'b:t:d:n' arg; do
        case "${arg}" in
            b) backcolor="${OPTARG}" ;;
            t) textcolor="${OPTARG}" ;;
            d) decotypes="${OPTARG}" ;;
            n) echo_opts="-n -e"     ;;
        esac
    done
    
    shift $((OPTIND - 1))
    
    echo ${echo_opts} "\e[$([[ -v backcolor ]] && echo -n "${backcolor}"; [[ -v textcolor ]] && echo -n ";${textcolor}"; [[ -v decotypes ]] && echo -n ";${decotypes}")m${*}\e[m"
}


# Show an INFO message
# $1: message string
_msg_info() {
    local echo_opts="-e"
    local arg
    local OPTIND
    local OPT
    while getopts 'n' arg; do
        case "${arg}" in
            n) echo_opts="${echo_opts} -n" ;;
        esac
    done
    shift $((OPTIND - 1))
    if [[ "${nocolor}" = true ]]; then
        echo ${echo_opts} "[${script_name}]    Info ${*}"
    else
        echo ${echo_opts} "$( echo_color -t '36' "[${script_name}]")    $( echo_color -t '32' 'Info') ${*}"
    fi
}


# Show an Warning message
# $1: message string
_msg_warn() {
    local echo_opts="-e"
    local arg
    local OPTIND
    local OPT
    while getopts 'n' arg; do
        case "${arg}" in
            n) echo_opts="${echo_opts} -n" ;;
        esac
    done
    shift $((OPTIND - 1))
    if [[ "${nocolor}" = true ]]; then
        echo ${echo_opts} "[${script_name}] Warning ${*}"
    else
        echo ${echo_opts} "$( echo_color -t '36' "[${script_name}]") $( echo_color -t '33' 'Warning') ${*}" >&2
    fi
}


# Show an debug message
# $1: message string
_msg_debug() {
    local echo_opts="-e"
    local arg
    local OPTIND
    local OPT
    while getopts 'n' arg; do
        case "${arg}" in
            n) echo_opts="${echo_opts} -n" ;;
        esac
    done
    shift $((OPTIND - 1))
    if [[ "${debug}" = true ]]; then
        if [[ "${nocolor}" = true ]]; then
            echo ${echo_opts} "[${script_name}]   Debug ${*}"
        else
            echo ${echo_opts} "$( echo_color -t '36' "[${script_name}]")   $( echo_color -t '35' 'Debug') ${*}"
        fi
    fi
}


# Show an ERROR message then exit with status
# $1: message string
# $2: exit code number (with 0 does not exit)
_msg_error() {
    local echo_opts="-e"
    local arg
    local OPTIND
    local OPT
    local OPTARG
    while getopts 'n' arg; do
        case "${arg}" in
            n) echo_opts="${echo_opts} -n" ;;
        esac
    done
    shift $((OPTIND - 1))
    if [[ "${nocolor}" = true ]]; then
        echo ${echo_opts} "[${script_name}]   Error ${1}"
    else
        echo ${echo_opts} "$( echo_color -t '36' "[${script_name}]")   $( echo_color -t '31' 'Error') ${1}" >&2
    fi
    if [[ -n "${2:-}" ]]; then
        exit ${2}
    fi
}

# rm helper
# Delete the file if it exists.
# For directories, rm -rf is used.
# If the file does not exist, skip it.
# remove <file> <file> ...
remove() {
    local _list
    local _file
    _list=($(echo "$@"))
    for _file in "${_list[@]}"; do
        if [[ -f ${_file} ]]; then
            _msg_debug "Removeing ${_file}"
            rm -f "${_file}"
            elif [[ -d ${_file} ]]; then
            _msg_debug "Removeing ${_file}"
            rm -rf "${_file}"
        fi
    done
}

# Parse options
if [[ -z "${@}" ]]; then
    _usage 0
fi

_opt_short="h,r:,a:sf"
_opt_long="help,repo:,arch:,skip,force,nocolor"

OPT=$(getopt -o ${_opt_short} -l ${_opt_long} -- "${@}")
if [[ ${?} != 0 ]]; then
    exit 1
fi

eval set -- "${OPT}"
unset OPT
unset _opt_short
unset _opt_long

while :; do
    case ${1} in
        --help | -h)
            _usage 0
            shift 1
            ;;
        --repo | -r)
            repo="${2}"
            shift 2
            ;;
        --arch | -a)
            arch="${2}"
            shift 2
            ;;
        --force | -f)
            force=true
            shift 1
            ;;
        --skip | -s)
            skip=true
            shift 1
            ;;
        --nocolor)
            nocolor=true
            shift 1
            ;;
        --) 
            shift 1
            break
            ;;
        *)
            _msg_error "Invalid argument '${1}'"
            _usage 1
            ;;
    esac
done

echo ${@}

for pkg in ${@}; do
    if [[ "${force}" = true ]]; then
        rm -rf "${script_path}/${repo}/${arch}/${pkg}"
    elif [[ -d "${script_path}/${repo}/${arch}/${pkg}" ]]; then
        _msg_error "${pkg} has already been added."
        if [[ "${skip}" = true ]]; then
            continue
        else
            exit 1
        fi
    fi
    if [[ ! "$(curl -sL "https://www.archlinux.org/packages/search/json/?name=${pkg}" | jq .results)" = "[]" ]]; then
        mkdir -p "${script_path}/${repo}/${arch}/"
        (
            cd "${script_path}/${repo}/${arch}/"
            asp export "${pkg}"
        )
    else
        mkdir -p "${script_path}/${repo}/${arch}/${pkg}"
        git clone "https://aur.archlinux.org/${pkg}.git" "${script_path}/${repo}/${arch}/${pkg}"
        rm -rf "${script_path}/${repo}/${arch}/${pkg}/.git"
    fi
done
