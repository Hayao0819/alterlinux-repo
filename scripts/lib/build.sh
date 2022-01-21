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
    # _Pkg変数: PKGBUILDへのフルパス
    while read -r _Pkg; do
        # Update repo
        BuildPkg "$_Arch" "$_Pkg"
        MovePkgToPool "$_Arch" "$_Repo" "$_Pkg"
    done < <(GetPkgbuildList "$(basename "$_Repo")")

    # Update repo

}
