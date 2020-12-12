#!/usr/bin/env bash

script_path="$( cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )"

set -eu

for DIR in $(find "${script_path}" -type f -name "PKGBUILD" | xargs realpath | xargs dirname); do
    PACKAGE="$(basename "${DIR}")"

    if [[ "${PACKAGE}" = "filesystem" ]]; then
        continue
    fi

    if [[ ! "$(curl -sL "https://www.archlinux.org/packages/search/json/?name=${PACKAGE}" | jq .results)" = "[]" ]]; then
        mkdir -p "${DIR}"
        (
            cd "${DIR}/../"
            rm -rf "${PACKAGE}"
            asp export "${PACKAGE}"
        )
    else
        mkdir -p "${script_path}/temp/${PACKAGE}"
        git clone "https://aur.archlinux.org/${PACKAGE}.git" "${script_path}/temp/${PACKAGE}"
        if [[ -n "$(ls "${script_path}/temp/${PACKAGE}")" ]]; then
            rm -rf "${DIR}"
            mv "${script_path}/temp/${PACKAGE}" "${DIR}"
            rm -rf "${DIR}/.git"
        fi
    fi
done
