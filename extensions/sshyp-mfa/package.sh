#!/bin/sh

version='1.5.1.2'
if [ -z "$2" ]; then
    revision=1
else
    revision="$2"
fi

_create_hpkg() {
    printf '\npackaging for Haiku...\n'
    mkdir -p output/haikutemp/lib/sshyp/extensions
    printf "name			sshyp_mfa
version			"$version"-"$revision"
architecture		any
summary			\"An MFA (TOTP/Steam) key generator for the sshyp password manager\"
description		\"sshyp-mfa is an extension for the sshyp password manager that reads MFA data from sshyp entries and generates generic TOTP and Steam keys.\"
packager		\"Randall Winkhart <idgr at tutanota dot com>\"
vendor			\"Randall Winkhart\"
licenses {
		\"GNU GPL v3\"
}
copyrights {
	\"2021-2023 Randall Winkhart\"
}
provides {
	sshyp_mfa = "$version"
}
requires {
	sshyp_client
}
urls {
	\"https://github.com/rwinkhart/sshyp-labs\"
}
" > output/haikutemp/.PackageInfo
    cp ./sshyp-mfa.py output/haikutemp/lib/sshyp/sshyp-mfa
    printf '[config]\ninput = copy -m\noutput = /system/lib/sshyp/sshyp-mfa\n' > ./output/haikutemp/lib/sshyp/extensions/sshyp-mfa.ini
    sed -i '1 s/.*/#!\/bin\/env\ python3.11/' output/haikutemp/lib/sshyp/sshyp-mfa
    cd output/haikutemp
    package create -b HAIKU-sshyp_mfa-"$version"-"$revision"_all.hpkg
    package add HAIKU-sshyp_mfa-"$version"-"$revision"_all.hpkg lib
    cd ../..
    mv output/haikutemp/HAIKU-sshyp_mfa-"$version"-"$revision"_all.hpkg output/
    rm -rf output/haikutemp
    printf "\nHaiku packaging complete\n\n"
} &&

_create_termux() {
    printf '\npackaging for Termux...\n'
    mkdir -p output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/DEBIAN \
        output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/lib/sshyp/extensions
    printf "Package: sshyp-mfa
Version: $version
Section: utils
Architecture: all
Maintainer: Randall Winkhart <idgr at tutanota dot com>
Description: An MFA (TOTP/Steam) key generator for the sshyp password manager
Depends: sshyp-client
Priority: optional
Installed-Size: 100
" > output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/DEBIAN/control
    cp ./sshyp-mfa.py output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/lib/sshyp/sshyp-mfa
    printf '[config]\ninput = copy -m\noutput = /data/data/com.termux/files/usr/lib/sshyp/sshyp-mfa\n' > ./output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/lib/sshyp/extensions/sshyp-mfa.ini
    dpkg-deb --build --root-owner-group output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/
    mv output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux.deb output/TERMUX-sshyp-mfa_"$version"-"$revision"_all.deb
    rm -rf output/termuxtemp
    printf '\nTermux packaging complete\n\n'
} &&

case "$1" in
    haiku)
        _create_hpkg
        ;;
    termux)
        _create_termux
        ;;
    *)
    printf '\nusage: package.sh [target] <revision>\n\ntargets: haiku termux\n\n'
    ;;
esac
