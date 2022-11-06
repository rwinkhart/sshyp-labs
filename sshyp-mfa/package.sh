#!/usr/bin/env bash

version=$(sed -n '1{p;q}' ../version)
if [ -z "$2" ]; then
    revision=1
else
    revision="$2"
fi

_create_generic() {
    echo -e '\npackaging as generic...\n'
    mkdir -p output/generictemp/usr/{bin,lib/sshyp,share/man/man1}
    cp -r lib/. output/generictemp/usr/lib/sshyp/
    ln -s /usr/lib/sshyp/sshyp-mfa.py output/generictemp/usr/bin/sshyp-mfa
    cp -r share output/generictemp/usr/
    cp extra/manpage output/generictemp/usr/share/man/man1/sshyp-mfa.1
    gzip output/generictemp/usr/share/man/man1/sshyp-mfa.1
    tar -C output/generictemp -cvJf output/sshyp-mfa-"$version".tar.xz usr/
    rm -rf output/generictemp
    sha512="$(sha512sum output/sshyp-mfa-"$version".tar.xz | awk '{print $1;}')"
    echo -e "\nsha512 sum:\n$sha512"
    echo -e "\ngeneric packaging complete\n"
} &&

_create_pkgbuild() {
    source='https://github.com/rwinkhart/sshyp-labs/releases/download/v$pkgver/sshyp-mfa-$pkgver.tar.xz'
    echo -e '\ngenerating PKGBUILD...'
    echo "# Maintainer: Randall Winkhart <idgr at tutanota dot com>
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

    tar xf sshyp-mfa-"\"\$pkgver\"".tar.xz -C "\"\${pkgdir}\""

}
" > output/PKGBUILD
    echo -e "\nPKGBUILD generated\n"
} &&

_create_apkbuild() {
    source='https://github.com/rwinkhart/sshyp-labs/releases/download/v$pkgver/sshyp-mfa-$pkgver.tar.xz'
    echo -e '\ngenerating APKBUILD...'
    echo "# Maintainer: Randall Winkhart <idgr@tutanota.com>
pkgname=sshyp-mfa
pkgver="$version"
pkgrel="$revision"
pkgdesc='An MFA (TOTP/Steam) key generator for the sshyp password manager'
options=!check
url='https://github.com/rwinkhart/sshyp-labs'
arch='noarch'
license='GPL-3.0-only'
depends='sshyp'
source=\""$source"\"

package() {
    mkdir -p "\"\$pkgdir\""
    cp -r "\"\$srcdir/usr/"\" "\"\$pkgdir\""
}

sha512sums=\"
"$sha512'  'sshyp-mfa-\"\$pkgver\".tar.xz"
\"
" > output/APKBUILD
    echo -e "\nAPKBUILD generated\n"
} &&

_create_hpkg() {
    echo -e '\npackaging for Haiku...\n'
    mkdir -p output/haikutemp/{bin,lib/sshyp,documentation/{man/man1,packages/sshyp-mfa}}
    echo "name			sshypmfa
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
	\"2021-2022 Randall Winkhart\"
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
    package create -b sshyp-mfa-"$version"-"$revision"_all.hpkg
    package add sshyp-mfa-"$version"-"$revision"_all.hpkg bin lib documentation
    cd ../..
    mv output/haikutemp/sshyp-mfa-"$version"-"$revision"_all.hpkg output/
    rm -rf output/haikutemp
    echo -e "\nHaiku packaging complete\n"
} &&

_create_deb() {
    echo -e '\npackaging for Debian/Ubuntu...\n'
    mkdir -p output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/{DEBIAN,usr/{lib/sshyp,bin,share/man/man1}}
    echo "Package: sshyp-mfa
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
    dpkg-deb --build --root-owner-group output/debiantemp/sshyp-mfa_"$version"-"$revision"_all/
    mv output/debiantemp/sshyp-mfa_"$version"-"$revision"_all.deb output/
    rm -rf output/debiantemp
    echo -e "\nDebian/Ubuntu packaging complete\n"
} &&

_create_termux() {
    echo -e '\npackaging for Termux...\n'
    mkdir -p output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/{DEBIAN,data/data/com.termux/files/usr/{lib/sshyp,bin,share/man/man1}}
    echo "Package: sshyp-mfa
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
    mv output/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux.deb output/
    rm -rf output/termuxtemp
    echo -e "\nTermux packaging complete\n"
} &&

_create_rpm() {
    echo -e '\npackaging for Fedora...\n'
    rm -rf ~/rpmbuild
    rpmdev-setuptree
    cp output/sshyp-mfa-"$version".tar.xz ~/rpmbuild/SOURCES
    echo "Name:           sshyp-mfa
Version:        "$version"
Release:        "$revision"
Summary:        An MFA (TOTP/Steam) key generator for the sshyp password manager
BuildArch:      noarch
License:        GPL-3.0-only
URL:            https://github.com/rwinkhart/sshyp-labs
Source0:        sshyp-mfa-"$version".tar.xz
Requires:       sshyp
%description
sshyp-mfa is an extension for the sshyp password manager that reads MFA data from sshyp entries and generates generic TOTP and Steam keys.
%install
tar xf %{_sourcedir}/sshyp-mfa-"$version".tar.xz -C %{_sourcedir}
cp -r %{_sourcedir}/usr %{buildroot}
%files
/usr/bin/sshyp-mfa
/usr/lib/sshyp/sshyp-mfa.py
%license /usr/share/licenses/sshyp-mfa/license
%doc /usr/share/man/man1/sshyp-mfa.1.gz
" > ~/rpmbuild/SPECS/sshyp-mfa.spec
rpmbuild -bb ~/rpmbuild/SPECS/sshyp-mfa.spec
mv ~/rpmbuild/RPMS/noarch/* output/
rm -rf ~/rpmbuild
echo -e "\nFedora packaging complete\n"
} &&

_create_freebsd_pkg() {
    echo -e '\npackaging for FreeBSD...\n'
    mkdir -p output/freebsdtemp/usr/{lib/sshyp,bin,share/man/man1}
    echo "name: sshyp-mfa
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
echo "/usr/bin/sshyp-mfa
/usr/lib/sshyp/sshyp-mfa.py
/usr/share/licenses/sshyp-mfa/license
/usr/share/man/man1/sshyp-mfa.1.gz
" > output/freebsdtemp/plist
cp -r lib/. output/freebsdtemp/usr/lib/sshyp/
ln -s /usr/lib/sshyp/sshyp-mfa.py output/freebsdtemp/usr/bin/sshyp-mfa
cp -r share output/freebsdtemp/usr/
cp extra/manpage output/freebsdtemp/usr/share/man/man1/sshyp-mfa.1
gzip output/freebsdtemp/usr/share/man/man1/sshyp-mfa.1
pkg create -m output/freebsdtemp/ -r output/freebsdtemp/ -p output/freebsdtemp/plist -o output/
rm -rf output/freebsdtemp
echo -e "\nFreeBSD packaging complete\n"
} &&

if [ "$1" == "generic" ]; then  # build scripts
    _create_generic
elif [ "$1" == "pkgbuild" ]; then
    _create_generic
    _create_pkgbuild
elif [ "$1" == "apkbuild" ]; then
    _create_generic
    _create_apkbuild
elif [ "$1" == "haiku" ]; then  # distribution packages
    _create_hpkg
elif [ "$1" == "debian" ]; then
    _create_deb
elif [ "$1" == "termux" ]; then
    _create_termux
elif [ "$1" == "fedora" ]; then
    _create_generic
    _create_rpm
elif [ "$1" == "freebsd" ]; then
    _create_freebsd_pkg
elif [ "$1" == "buildable-arch" ]; then
    _create_generic
    _create_pkgbuild
    _create_apkbuild
    if [[ $(pacman -Q dpkg) == "dpkg"* ]]; then
        _create_deb
        _create_termux
    fi
    if [[ "$(pacman -Q freebsd-pkg)" == "freebsd-pkg"* ]]; then
        _create_freebsd_pkg
    fi
else
    echo -e '\nusage: package.sh [target] <revision>\n\ntargets:\n mainline: pkgbuild apkbuild haiku fedora debian\n experimental: freebsd termux\n other: buildable-arch\n'
fi
