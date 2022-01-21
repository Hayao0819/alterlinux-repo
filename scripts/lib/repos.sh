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
