#!/usr/bin/env bash

script_path="$( cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )"

set -eu

for DIR in $(find "${script_path}" -type f -name "PKGBUILD" | xargs realpath | xargs dirname); do
    PACKAGE="$(basename "${DIR}")"
    git clone "https://aur.archlinux.org/${PACKAGE}.git" "${script_path}/temp/${PACKAGE}"
    if [[ -n "$(ls "${script_path}/temp/${PACKAGE}")" ]]; then
        rm -rf "${DIR}"
        mv "${script_path}/temp/${PACKAGE}" "${DIR}"
        rm -rf "${DIR}/.git"
    fi
done
