SetupChroot_x86_64(){
    local CHROOT="$WorkDir/Chroot/x86_64/"
    MakeDir "$CHROOT"

    [[ -e "$CHROOT/root" ]] && return 0

    # Create chroot
    mkarchroot \
        -C "$MainDir/configs/pacman-x86_64.conf" \
        "$CHROOT/root" "${ChrootPkg[@]}"

    # Update package
    arch-nspawn "$CHROOT/root" pacman -Syyu
}

SetupChroot_i686(){
    local CHROOT="$WorkDir/Chroot/i686/"
    MakeDir "$CHROOT" "$WorkDir/Keyring"

    # Install archlinux32-keyring
    if ! pacman -Qq archlinux32-keyring && [[ "$(uname -m)" = "x86_64" ]]; then
        {
            cd "$WorkDir/Keyring" || return 1
            git clone "https://aur.archlinux.org/archlinux32-keyring"
            cd "archlinux32-keyring" || return 1
            SetupChroot_x86_64
            RunMakePkg "x86_64" "./PKGBUILD"
            local _Pkg
            while read -r _Pkg; do
                MsgWarn "Install $_Pkg"
                sudo pacman -U --noconfirm "$_Pkg"
            done < <(GetPkgListFromPKGBUILD "x86_64" "./PKGBUILD")
        }
    fi
        

    [[ -e "$CHROOT/root" ]] && return 0

    # Create chroot
    mkarchroot \
        -C "$MainDir/configs/pacman-i686.conf" \
        "$CHROOT/root" "${ChrootPkg[@]}"

    # Update package
    arch-nspawn "$CHROOT/root" pacman -Syyu
}

# RunMakePkg <ARCH> <PKGBUILD PATH>
RunMakePkg(){
    local MakeChrootPkg_Args=(-c -r "$WorkDir/Chroot/$1" -U "$ChrootUser")
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
    MakeDir "$_Pool"

    # Move
    while read -r _PkgFile; do
        for __File in "$_PkgFile" "$_PkgFile.sig"; do
            [[ -e "$__File" ]] && {
                MsgDebug "Move $__File to $_Pool"
                cp "$__File" "$_Pool"
                continue
            }
            MsgError "$__File does not exist"
        done
    done < <(GetPkgListFromPKGBUILD "$_Arch" "./PKGBUILD")
    return 0
}
