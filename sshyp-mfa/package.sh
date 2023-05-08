#!/bin/sh

version=$(sed -n '1{p;q}' ../version)
if [ -z "$2" ]; then
    revision=1
else
    revision="$2"
fi

_create_generic() {
    printf '\npackaging as generic...\n'
    mkdir -p output/generictemp/usr/bin \
        output/generictemp/usr/lib/sshyp \
        output/generictemp/usr/share/man/man1
    cp -r lib/. output/generictemp/usr/lib/sshyp/
    ln -s /usr/lib/sshyp/sshyp-mfa.py output/generictemp/usr/bin/sshyp-mfa
    cp -r share output/generictemp/usr/
    cp extra/manpage output/generictemp/usr/share/man/man1/sshyp-mfa.1
    gzip output/generictemp/usr/share/man/man1/sshyp-mfa.1
    XZ_OPT=-e6 tar -C output/generictemp -cvJf output/GENERIC-sshyp-mfa-"$version".tar.xz usr/
    rm -rf output/generictemp
    sha512="$(sha512sum output/GENERIC-sshyp-mfa-"$version".tar.xz | awk '{print $1;}')"
    printf '\ngeneric packaging complete\n\n'
} &&

_create_pkgbuild() {
    printf '\ngenerating PKGBUILD...\n'
    if [ "$1" = 'Deb' ]; then
        local source='https://github.com/rwinkhart/sshyp-labs/releases/download/v"$pkgver"/UBUNTU-sshyp-mfa_"$pkgver"-"$pkgrel"_all.deb'
        local decomp_target='data.tar.xz'
    else
        local source='https://github.com/rwinkhart/sshyp-labs/releases/download/v"$pkgver"/GENERIC-sshyp-mfa-"$pkgver".tar.xz'
        local decomp_target='GENERIC-sshyp-"$pkgver".tar.xz'
    fi
    printf "# Maintainer: Randall Winkhart <idgr at tutanota dot com>
pkgname=sshyp-mfa
pkgver="$version"
pkgrel="$revision"
pkgdesc='An MFA (TOTP/Steam) key generator for the sshyp password manager'
url='https://github.com/rwinkhart/sshyp-labs'
arch=('any')
license=('GPL-3.0-only')
depends=(sshyp)
source=(\""$source"\")
sha512sums=('"$sha512"')

package() {

    tar -xf $decomp_target -C "\"\${pkgdir}\""

}
" > output/PKGBUILD
    printf '\nPKGBUILD generated\n\n'
} &&

_create_apkbuild() {
    printf '\ngenerating APKBUILD...\n'
    if [ "$1" = 'Deb' ]; then
        local source="https://github.com/rwinkhart/sshyp-labs/releases/download/v\"\$pkgver\"/UBUNTU-sshyp-mfa_\"\$pkgver\"-"$revision"_all.deb"
        local sumsname="UBUNTU-sshyp-mfa_\"\$pkgver\"-"$revision"_all.deb"
        local processing='mkdir -p "$pkgdir"
    7z x "$srcdir"/* -o"$srcdir"
    tar -xf "$srcdir"/data.tar -C "$pkgdir"
    else
        local source='https://github.com/rwinkhart/sshyp-labs/releases/download/v"$pkgver"/GENERIC-sshyp-mfa-"$pkgver".tar.xz'
        local sumsname='GENERIC-sshyp-"$pkgver".tar.xz'
        local processing='mkdir -p "$pkgdir"
    cp -r "$srcdir/usr/" "$pkgdir"'
    fi
    printf "# Maintainer: Randall Winkhart <idgr@tutanota.com>
pkgname=sshyp-mfa
pkgver="$version"
pkgrel="$((revision-1))"
pkgdesc='An MFA (TOTP/Steam) key generator for the sshyp password manager'
options=!check
url='https://github.com/rwinkhart/sshyp-labs'
arch='noarch'
license='GPL-3.0-only'
depends='sshyp'
source=\""$source"\"

package() {
    $processing
}

sha512sums=\"
"$sha512"  "$sumsname"
\"
" > output/APKBUILD
    printf '\nAPKBUILD generated\n\n'
} &&

_create_hpkg() {
    printf '\npackaging for Haiku...\n'
    mkdir -p output/haikutemp/bin \
        output/haikutemp/lib/sshyp \
        output/haikutemp/documentation/man/man1 \
        output/haikutemp/documentation/packages/sshyp-mfa
    printf "name			sshypmfa
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
	sshypmfa = "$version"
	cmd:sshypmfa
}
requires {
	sshyp
}
urls {
	\"https://github.com/rwinkhart/sshyp-labs\"
}
" > output/haikutemp/.PackageInfo
    cp -r lib/. output/haikutemp/lib/sshyp/
    sed -i '1 s/.*/#!\/bin\/env\ python3.10/' output/haikutemp/lib/sshyp/sshyp-mfa.py
    ln -s /system/lib/sshyp/sshyp-mfa.py output/haikutemp/bin/sshyp-mfa
    cp -r share/licenses/sshyp-mfa/. output/haikutemp/documentation/packages/sshyp-mfa/
    cp extra/manpage output/haikutemp/documentation/man/man1/sshyp-mfa.1
    gzip output/haikutemp/documentation/man/man1/sshyp-mfa.1
    cd output/haikutemp
    package create -b HAIKU-sshyp-mfa-"$version"-"$revision"_all.hpkg
    package add HAIKU-sshyp-mfa-"$version"-"$revision"_all.hpkg bin lib documentation
    cd ../..
    mv output/haikutemp/HAIKU-sshyp-mfa-"$version"-"$revision"_all.hpkg output/
    rm -rf output/haikutemp
    printf "\nHaiku packaging complete\n\n"
} &&

_create_deb() {
    printf '\npackaging for Debian/Ubuntu...\n'
    mkdir -p output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/DEBIAN \
        output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/lib/sshyp \
        output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/bin \
        output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/share/man/man1
    printf "Package: sshyp-mfa
Version: $version
Section: utils
Architecture: all
Maintainer: Randall Winkhart <idgr at tutanota dot com>
Description: An MFA (TOTP/Steam) key generator for the sshyp password manager
Depends: sshyp
Priority: optional
Installed-Size: 100
" > output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/DEBIAN/control
    cp -r lib/. output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/lib/sshyp/
    ln -s /usr/lib/sshyp/sshyp-mfa.py output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/bin/sshyp-mfa
    cp -r share output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/
    cp extra/manpage output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/share/man/man1/sshyp-mfa.1
    gzip output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/share/man/man1/sshyp-mfa.1
    dpkg-deb --build --root-owner-group -z6 -Sextreme -Zxz output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/
    mv output/debiantemp/sshyp-mfa_"$version"-"$revision"_all.deb output/UBUNTU-sshyp_"$version"-"$revision"_all.deb
    rm -rf output/debiantemp
    sha512="$(sha512sum output/UBUNTU-sshyp-mfa_"$version"-"$revision"_all.deb | awk '{print $1;}')"
    printf '\nDebian/Ubuntu packaging complete\n\n'
} &&

_create_termux() {
    printf '\npackaging for Termux...\n'
    mkdir -p output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/DEBIAN \
        output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/lib/sshyp \
        output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/bin \
        output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/share/man/man1
    printf "Package: sshyp-mfa
Version: $version
Section: utils
Architecture: all
Maintainer: Randall Winkhart <idgr at tutanota dot com>
Description: An MFA (TOTP/Steam) key generator for the sshyp password manager
Depends: sshyp
Priority: optional
Installed-Size: 100
" > output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/DEBIAN/control
    cp -r lib/. output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/lib/sshyp/
    ln -s /data/data/com.termux/files/usr/lib/sshyp/sshyp-mfa.py output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/bin/sshyp-mfa
    cp -r share output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/
    cp extra/manpage output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/share/man/man1/sshyp-mfa.1
    gzip output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/share/man/man1/sshyp-mfa.1
    dpkg-deb --build --root-owner-group output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/
    mv output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux.deb output/TERMUX-sshyp_"$version"-"$revision"_all.deb
    rm -rf output/termuxtemp
    printf '\nTermux packaging complete\n\n'
} &&

_create_rpm() {
    printf '\npackaging for Fedora...\n'
    rm -rf ~/rpmbuild
    rpmdev-setuptree
    mkdir -p output/fedoratemp/usr/bin \
             output/fedoratemp/usr/lib/sshyp/extensions \
    mkdir -p output/fedoratemp/usr/bin \
        output/fedoratemp/usr/lib/sshyp \
        output/fedoratemp/usr/share/man/man1
    printf "Name:           sshyp-mfa
Version:        "$version"
Release:        "$revision"
Summary:        An MFA (TOTP/Steam) key generator for the sshyp password manager
BuildArch:      noarch
License:        GPL-3.0-only
URL:            https://github.com/rwinkhart/sshyp-labs
Source0:        GENERIC-FEDORA-sshyp-mfa-"$version".tar.xz
Requires:       sshyp
%%description
sshyp-mfa is an extension for the sshyp password manager that reads MFA data from sshyp entries and generates generic TOTP and Steam keys.
%%install
tar xf %%{_sourcedir}/GENERIC-FEDORA-sshyp-mfa-"$version".tar.xz -C %%{_sourcedir}
cp -r %%{_sourcedir}/usr %%{buildroot}
%%files
/usr/bin/sshyp-mfa
/usr/lib/sshyp/sshyp-mfa.py
/usr/lib/sshyp/extensions/sshyp-mfa
%%license /usr/share/licenses/sshyp-mfa/license
%%doc /usr/share/man/man1/sshyp-mfa.1.gz
" > ~/rpmbuild/SPECS/sshyp-mfa.spec
ln -s /usr/lib/sshyp/sshyp-mfa.py output/fedoratemp/usr/bin/sshyp-mfa
cp -r share output/fedoratemp/usr/
cp extra/manpage output/fedoratemp/usr/share/man/man1/sshyp-mfa.1
gzip output/fedoratemp/usr/share/man/man1/sshyp-mfa.1
XZ_OPT=-e6 tar -C output/fedoratemp -cvJf output/GENERIC-FEDORA-sshyp-mfa-"$version".tar.xz usr/
rm -rf output/fedoratemp
cp output/GENERIC-FEDORA-sshyp-mfa-"$version".tar.xz ~/rpmbuild/SOURCES
rpmbuild -bb ~/rpmbuild/SPECS/sshyp-mfa.spec
mv ~/rpmbuild/RPMS/noarch/sshyp-mfa-"$version"-"$revision".noarch.rpm output/FEDORA-sshyp-mfa-"$version"-"$revision".noarch.rpm
rm -rf ~/rpmbuild
printf '\nFedora packaging complete\n\n'
} &&

_create_freebsd_pkg() {
    printf '\npackaging for FreeBSD...\n'
    mkdir -p output/freebsdtemp/usr/lib/sshyp \
        output/freebsdtemp/usr/bin \
        output/freebsdtemp/usr/share/man/man1
    printf "name: sshyp-mfa
version: \""$version"\"
abi = \"FreeBSD:13:*\";
arch = \"freebsd:13:*\";
origin: security/sshyp-mfa
comment: \"a sshyp extension\"
desc: \"an MFA (TOTP/Steam) key generator for the sshyp password manager\"
maintainer: <idgr at tutanota dot com>
www: https://github.com/rwinkhart/sshyp-labs
prefix: /
\"deps\" : {
                   \"sshyp\" : {
                      \"origin\" : \"security/sshyp\"
                   },
                },
" > output/freebsdtemp/+MANIFEST
printf "/usr/bin/sshyp-mfa
/usr/lib/sshyp/sshyp-mfa.py
/usr/lib/sshyp/extensions/sshyp-mfa
/usr/share/licenses/sshyp-mfa/license
/usr/share/man/man1/sshyp-mfa.1.gz
" > output/freebsdtemp/plist
cp -r lib/. output/freebsdtemp/usr/lib/sshyp/
ln -s /usr/lib/sshyp/sshyp-mfa.py output/freebsdtemp/usr/bin/sshyp-mfa
cp -r share output/freebsdtemp/usr/
cp extra/manpage output/freebsdtemp/usr/share/man/man1/sshyp-mfa.1
gzip output/freebsdtemp/usr/share/man/man1/sshyp-mfa.1
pkg create -m output/freebsdtemp/ -r output/freebsdtemp/ -p output/freebsdtemp/plist -o output/
mv output/sshyp-mfa-"$version".pkg output/FREEBSD-sshyp-mfa-"$version"-"$revision".pkg
rm -rf output/freebsdtemp
printf '\nFreeBSD packaging complete\n\n'
} &&

case "$1" in
    pkgbuild)
        _create_deb
        _create_pkgbuild Deb
        ;;
    apkbuild)
        _create_deb
        _create_apkbuild Deb
        ;;
    haiku)
        _create_hpkg
        ;;
    debian)
        _create_deb
        ;;
    termux)
        _create_termux
        ;;
    fedora)
        _create_rpm
        ;;
    freebsd)
        _create_freebsd_pkg
        ;;
    buildable-arch)
        _create_deb
        _create_pkgbuild Deb
        _create_apkbuild Deb
        case "$(pacman -Q freebsd-pkg)" in
            freebsd-pkg*)
            _create_freebsd_pkg
            ;;
        esac
        ;;
    *)
    printf '\nusage: package.sh [target] <revision>\n\ntargets:\n mainline: pkgbuild apkbuild fedora debian haiku freebsd\n experimental: termux\n groups: buildable-arch\n\n'
    ;;
esac
