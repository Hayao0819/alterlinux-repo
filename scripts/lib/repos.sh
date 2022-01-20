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
