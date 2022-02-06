# GetPkgListFromPKGBUILD <ARCH> <PKGBUILD>
GetPkgListFromPKGBUILD(){
    local _Arch="$1" _PkgBuild="$2"
    cd "$(dirname "$_PkgBuild")" || return 1
    setarch "$_Arch" sudo -u "$ChrootUser" makepkg --ignorearch --packagelist -p "$(basename "${_PkgBuild}")"
}
