GetRepoList(){
    GetRepoFullPath| GetBaseName
}

GetRepoFullPath(){
    find "${ReposDir}" -mindepth 1 -maxdepth 1 -type d
}
