#!/usr/bin/env bash

script_path="$( cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )"

for PKGBUILD in $(find "${script_path}" -type f -name "PKGBUILD" | xargs realpath | xargs dirname); do
    cd "${PKGBUILD}"
    echo "==> Creating SRCINFO of $(basename ${PKGBUILD})"
    makepkg --printsrcinfo > "${PKGBUILD}/.SRCINFO"
done
