SetupChroot_x86_64(){
    local CHROOT="$WorkDir/x86_64/"
    mkdir -p "$CHROOT/root"

    mkarchroot \
        -C "$MainDir/configs/pacman-x86_64.conf" \
        "$CHROOT/root" "${ChrootPkg[@]}"
}


BuildPkg(){
    true
}
