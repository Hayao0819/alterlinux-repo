SetupChroot_x86_64(){
    local CHROOT="$WorkDir/x86_64/"
    mkdir -p "$CHROOT"

    [[ -e "$CHROOT/root" ]] && return 0

    # Create chroot
    mkarchroot \
        -C "$MainDir/configs/pacman-x86_64.conf" \
        "$CHROOT/root" "${ChrootPkg[@]}"

    # Update package
    arch-nspawn "$CHROOT/root" pacman -Syyu
}


#BuildPkg <ARCH> <PKGBUILD PATH>
BuildPkg(){
    local MakeChrootPkg_Args=(-c -r "$WorkDir/$1" -U "$ChrootUser")
    local Makepkg_Args=()
    local Pkgbuild="${2}"

    # Move to dir
    cd "$(dirname "$Pkgbuild")" || {
        MsgError "Failed to move the PKGBUILD's directory."
        return 1
    }

    # Run makechrootpkg
    makechrootpkg "${MakeChrootPkg_Args[@]}" -- "${Makepkg_Args[@]}"
}

# MovePkgToPool <ARCH> <REPO NAME> <PKGBUILD Path>
MovePkgToPool(){
    local _Arch="$1" _Repo="$2" _Pkgbuild="$3" _PkgFile
    local _Pool="${OutDir}/$_Repo/pool/packages"

    # Move to dir
    cd "$(dirname "$_Pkgbuild")" || {
        MsgError "Failed to move the PKGBUILD's directory."
        return 1
    }

    # Make dir
    mkdir -p "$_Pool"

    # Move
    while read -r _PkgFile; do
        for __File in "$_PkgFile" "$_PkgFile.sig"; do
            [[ -e "$__File" ]] && {
                cp "$__File" "$_Pool"
                continue
            }
            MsgError "$__File does not exist"
        done
    done < <(setarch "$_Arch" sudo -u "$ChrootUser" makepkg --packagelist)
    return 0
}
