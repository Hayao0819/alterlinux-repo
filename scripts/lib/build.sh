# BuildPkg <arch> <repo name> <pkgbuild1> <pkgbuild2> ...
# 指定されたリポジトリ、アーキテクチャのパッケージをビルドします
BuildPkg(){
    local _Arch="$1" _RepoName="$2"
    local _Repo="$OutDir/$_RepoName"
    shift 2
    _ToBuildPkg=("$@")

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
        RunMakePkg "$_Arch" "$_Pkg"
        MovePkgToPool "$_Arch" "$_RepoName" "$_Pkg"
    done < <(PrintArray "${_ToBuildPkg[@]}")

    # Update repo
    UpdateRepoDb "$(basename "$_Repo")"
}

# BuildALlPkg <repo name>
# 指定されたリポジトリの全てのパッケージを全てのアーキテクチャでビルドします
BuildAllPkg(){
    local _RepoName="$1" _PkgList _ArchList
    readarray -t _PkgList < <(GetPkgbuildList "$_RepoName")
    BuildAllArch "$_RepoName" "${_PkgList[@]}"
}

# BiildAllArch <repo name> <pkgbuild1> <pkgbuild2> ...
# 指定されたリポジトリの指定されたパッケージを全てのアーキテクチャでビルドます
BuildAllArch(){
    local _RepoName="$1"
    shift 1
    local _PkgList=("$@") _ArchList
    readarray -t _ArchList < <(GetRepoArchList "$_RepoName")

    for _Arch in "${_ArchList[@]}"; do
        BuildPkg "$_Arch" "$_RepoName" "${_PkgList[@]}"
    done
}

# 全てのリポジトリの全てのパッケージをビルドします
BuildAllPkgInAllRepo(){
    local _repo _Arch
    while read -r _repo; do
        MsgDebug "Found repository: $_repo"
        BuildAllPkg "${_repo}"
    done < <(GetRepoList)
}
