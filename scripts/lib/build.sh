# RunBuildAllPkg <repo dir> <arch>
RunBuildAllPkg(){
    local _Repo="${1}" _Arch="$2"

    # Check arch
    CheckCorrectArch "$_Arch"

    # Load configs
    LoadShellFIles "$_Repo/repo-config.sh"
    LoadShellFIles "$MainDir/configs/config-$_Arch.sh"

    # Setup chroot
    eval "SetupChroot_$_Arch"

    # Run makepkg
    

    # Update repo
}
