GetRepoList(){
    GetRepoFullPath| GetBaseName
}

GetRepoFullPath(){
    find "${ReposDir}" -mindepth 1 -maxdepth 1 -type d
}

# GetPkgbuildList <repo name>
GetPkgbuildList(){
    local _Repo="$ReposDir/$1"

    find "$_Repo" -name "PKGBUILD" -type f -mindepth 1
}

# UpdateRepoDb <repo name>
UpdateRepoDb(){
    local _Repo="$1"
    local _Pool="${OutDir}/$_Repo/pool/packages"
    local _RepoDir="${OutDir}/$_Repo/os/"
    local _File _Arch _Path

    for _Arch in "${RepoArch[@]}"; do
        mkdir -p "$_RepoDir/$_Arch"
    done

    while read -r _Path; do
        _File="$(basename "$_Path")"
        _Arch="${_File##*-}"
        _Arch="${_Arch%%.pkg.tar.*}"

        case "$_Arch" in
            "any")
                PrintArray "${RepoArch[@]}" | xargs -I{} ln -s "../pool/packages/$_File" "$_RepoDir/{}/${_File}"
                PrintArray "${RepoArch[@]}" | xargs -I{} repo-add "$_RepoDir/$_Repo.db.tar.gz" "$_RepoDir/{}/$_File" 
                ;;
            *)
                ln -s "../pool/packages/$_File" "$_RepoDir/$_Arch/${_File}"
                repo-add "$_RepoDir/$_Repo.db.tar.gz" "$_RepoDir/$_Arch/$_File" 
                ;;
        esac

    done < <(find "$_Pool" -mindepth 1 -type f)

}

# CheckCorrectArch <arch>
CheckCorrectArch(){
    local _Err=0 _Arch="$1"

    CheckFunctionDefined "SetupChroot_$_Arch" || {
        MsgError "Setup chroot for $_Arch is not implemented."
        (( _Err+=1 ))
    }

    test -f "$MainDir/configs/pacman-$_Arch.conf" || {
        MsgError "pacman.conf for $_Arch does not exist"
        (( _Err+=1 ))
    }

    test -f "$MainDir/configs/config-$_Arch.sh" || {
        MsgWarn "Global config for $_Arch does not exist"
    }

    (( _Err == 0 )) || {
        MsgError "$_Err errors about $_Arch are found."
        return 1
    }
}


# GetRepoArchList <repo name>
GetRepoArchList(){ {
    local _RepoName="$1"
    local _Repo="$ReposDir/$_RepoName"
    LoadShellFIles "$_Repo/repo-config.sh"
    PrintArray "${RepoArch[@]}"
} }


# CreateRepoLockFile <arch> <repo> <pkgbuild>
CreateRepoLockFile(){
    local _Arch="$1" _RepoName="$2" _PkgBuild="$3"
    local _LockFileDir="$WorkDir/LockFile/"
    local _RepoFile="$_LockFileDir/$_RepoName"

    [[ -e "$_RepoFile" ]] || { echo > "$_RepoFile"; }
    readarray _FileList < <(makepkg --ignorearch --packagelist | GetBaseName)

    local _Pkg
    for _Pkg in "${_FileList[@]}"; do
        echo "$_Arch/$_Pkg" >> "$_RepoFile"
    done
}


# CheckAlreadyBuilt <arch> <repo> <pkgbuild>
# return 1 => already built
# return 0 -> not built yet
CheckAlreadyBuilt(){
    local _Arch="$1" _RepoName="$2" _PkgBuild="$3"
    local _LockFileDir="$WorkDir/LockFile/"
    local _RepoFile="$_LockFileDir/$_RepoName"

    [[ -e "$_RepoFile" ]] || return 0
    readarray _FileList < <(
        cd "$(dirname "$_PkgBuild")" || return 0
        makepkg --ignorearch --packagelist | GetBaseName)

    for _Pkg in "${_FileList[@]}"; do
        ! grep -qx "$_Arch/$_Pkg" "$_RepoFile" || return 1
    done
    return 0
}

