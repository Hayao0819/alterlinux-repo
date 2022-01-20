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
