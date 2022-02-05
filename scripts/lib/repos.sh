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

# RunEachArch <repo name> <cmmands>
# {} will be replaced to architecture name
RunEachArch(){
    local _Arch _Cmd _Repo="$1"
    local _CmdArray=()
    shift 1 || return 0

    while read -r _Arch; do
        _CmdArray=()
        for _Cmd in "$@"; do
            # shellcheck disable=SC2001
            _CmdArray+=("$(sed "s|{}|$_Arch|g" <<< "${_Cmd}")")
        done
        "${_CmdArray[@]}"
    done < <(GetRepoArchList "$_Repo")
}

# UpdateRepoDb <repo name>
UpdateRepoDb(){
    local _Repo="$1"
    local _Pool="${OutDir}/$_Repo/pool/packages"
    local _RepoDir="${OutDir}/$_Repo/os/"
    local _File _Arch _Path

    while read -r _Path; do
        _File="$(basename "$_Path")"
        _Arch="${_File##*-}"
        _Arch="${_Arch%%.pkg.tar.*}"
        MsgDeBug "Meta Update: $_Path"

        # Setup files
        rm -rf "${_RepoDir:?}/${_Arch:?}/${_File:?}" 

        # Function to add pakage to db
        local _Add_Pkg
        _Add_Pkg(){
            local _Arch="$1" _Symlink="$_RepoDir/$_Arch/${_File}"
            mkdir -p "$_RepoDir/$_Arch"
            if [[ -n "$GPGKey" ]]; then
                rm -rf "${_Path}.sig"
                gpg --output "${_Path}.sig" -u "$GPGKey" --detach-sig "${_Path}"
            fi
            rm -rf "$_Symlink"
            ln -s "../../pool/packages/$_File" "$_Symlink"
            repo-add "$_RepoDir/${_Arch}/$_Repo.db.tar.gz" "$_Symlink"
        }

        case "$_Arch" in
            "any")
                RunEachArch "$_Repo" _Add_Pkg "{}"
                ;;
            *)
                _Add_Pkg "$_Arch"
                ;;
        esac

    done < <(find "$_Pool" -name "*.pkg.tar.*" -mindepth 1 -maxdepth 1 -type f | grep -v ".sig$")

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
    if (( "${#OverRideRepoArch[@]}" > 0)); then
        PrintArray "${OverRideRepoArch[@]}"
    else
        LoadShellFIles "$_Repo/repo-config.sh"
        PrintArray "${RepoArch[@]}"
    fi
} }


# CreateRepoLockFile <arch> <repo> <pkgbuild>
CreateRepoLockFile(){
    local _Arch="$1" _RepoName="$2" _PkgBuild="$3"
    local _LockFileDir="$WorkDir/LockFile/"
    local _RepoFile="$_LockFileDir/$_RepoName"

    [[ -e "$_RepoFile" ]] || { echo > "$_RepoFile"; }
    readarray -t _FileList < <(
        cd "$(dirname "$_PkgBuild")" || return 0
        makepkg --ignorearch --packagelist | GetBaseName)

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
    readarray -t _FileList < <(
        cd "$(dirname "$_PkgBuild")" || return 0
        makepkg --ignorearch --packagelist | GetBaseName)

    local _Pkg
    for _Pkg in "${_FileList[@]}"; do
        ! grep -qx "$_Arch/$_Pkg" "$_RepoFile" || return 1
    done
    return 0
}

