SetupChroot_x86_64(){
    local CHROOT="$WorkDir/x86_64/"
    mkdir -p "$CHROOT"

    # Create chroot
    mkarchroot \
        -C "$MainDir/configs/pacman-x86_64.conf" \
        "$CHROOT/root" "${ChrootPkg[@]}"

    # Update package
    arch-nspawn "$CHROOT/root" pacman -Syyu
}


#BuildPkg <ARCH> <PKGBUILD PATH>
BuildPkg(){
    local MakeChrootPkg_Args=(-c -r "$WorkDir/$1")
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
