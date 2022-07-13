#!/bin/bash

# This script packages sshyp-mfa (from source) for various UNIX(-like) environments.
# Dependencies (Arch Linux): dpkg (packaging for Debian/Termux), freebsd-pkg (packaging for FreeBSD)
# Dependencies (Fedora) (can only package for self): rpmdevtools
# NOTE It is recommended to instead use the latest officially packaged and tagged release.

echo -e '\nOptions (please enter the number only):'
echo -e '\nPackage Formats:\n\n1. Haiku\n2. Debian&Ubuntu Linux\n3. Fedora Linux\n4. FreeBSD\n5. Termux\n6. Generic (used for PKGBUILD/APKBUILD)'
echo -e '\nBuild Scripts:\n\n7. Arch Linux (PKGBUILD)'
echo -e '\nOther:\n\n8. All (generates all distribution packages (excluding Haiku and Fedora, as these must be packaged on their respective distributions) and build scripts)\n'
read -n 1 -r -p "Distribution: " distro

echo -e '\n\nThe value entered in this field will only affect the version reported to the package manager. The latest source is used regardless.\n'
read -r -p "Version number: " version

echo -e '\nThe value entered in this field will only affect the revision number for build scripts.\n'
read -r -p "Revision number: " revision

if [ "$distro" == "7" ] || [ "$distro" == "8" ]; then
    echo -e '\nOptions (please enter the number only):'
    echo -e '\n1. GitHub Release Tag\n2. Local\n'
    read -r -p "Source (for build scripts): " source

    if [ "$source" == "1" ]; then
        source='https://github.com/rwinkhart/sshyp-labs/releases/download/v$pkgver/sshyp-mfa-$pkgver.tar.xz'
    else
        source=local://sshyp-mfa-"$version".tar.xz
    fi
fi

mkdir -p packages

if [ "$distro" == "1" ]; then
    echo -e '\nPackaging for Haiku...\n'
    mkdir -p packages/haikutemp/documentation/{man/man1,packages/sshyp-mfa}
    echo "name			sshyp-mfa
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
	sshyp-mfa = "$version"
	cmd:sshyp-mfa
}
requires {
	sshyp
	python3
}
urls {
	\"https://github.com/rwinkhart/sshyp-labs\"
}
" > packages/haikutemp/.PackageInfo
    cp -r bin packages/haikutemp/
    ln -s /bin/sshyp-mfa.py packages/haikutemp/bin/sshyp-mfa
    cp -r share/licenses/sshyp-mfa/ packages/haikutemp/documentation/packages/
    cp extra/manpage packages/haikutemp/documentation/man/man1/sshyp-mfa.1
    gzip packages/haikutemp/documentation/man/man1/sshyp-mfa.1
    cd packages/haikutemp
    package create -b sshyp-mfa-"$version"-"$revision"_all.hpkg
    package add sshyp-mfa-"$version"-"$revision"_all.hpkg bin documentation
    cd ../..
    mv packages/haikutemp/sshyp-mfa-"$version"-"$revision"_all.hpkg packages/
    rm -rf packages/haikutemp
    echo -e "\nHaiku packaging complete.\n"
fi

if [ "$distro" == "2" ] || [ "$distro" == "8" ]; then
    echo -e '\nPackaging for Debian...\n'
    mkdir -p packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/{DEBIAN,usr/share/man/man1}
    echo "Package: sshyp-mfa
Version: $version
Section: utils
Architecture: all
Maintainer: Randall Winkhart <idgr at tutanota dot com>
Description: An MFA (TOTP/Steam) key generator for the sshyp password manager
Depends: sshyp, python3
Priority: optional
Installed-Size: 100
" > packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/DEBIAN/control
    cp -r bin packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/
    ln -s /usr/bin/sshyp-mfa.py packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/bin/sshyp-mfa
    cp -r share packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/
    cp extra/manpage packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/share/man/man1/sshyp-mfa.1
    gzip packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/usr/share/man/man1/sshyp-mfa.1
    dpkg-deb --build --root-owner-group packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all/
    mv packages/debiantemp/sshyp-mfa_"$version"-"$revision"_all.deb packages/
    rm -rf packages/debiantemp
    echo -e "\nDebian packaging complete.\n"
fi

if [ "$distro" == "5" ] || [ "$distro" == "8" ]; then
    echo -e '\nPackaging for Termux...\n'
    mkdir -p packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/{data,DEBIAN}
    mkdir -p packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/share/man/man1
    echo "Package: sshyp-mfa
Version: $version
Section: utils
Architecture: all
Maintainer: Randall Winkhart <idgr at tutanota dot com>
Description: An MFA (TOTP/Steam) key generator for the sshyp password manager
Depends: sshyp, python3
Priority: optional
Installed-Size: 100
" > packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/DEBIAN/control
    cp -r bin packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/
    ln -s /usr/bin/sshyp-mfa.py packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/bin/sshyp-mfa
    cp -r share packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/
    cp extra/manpage packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/share/man/man1/sshyp-mfa.1
    gzip packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/data/data/com.termux/files/usr/share/man/man1/sshyp-mfa.1
    dpkg-deb --build --root-owner-group packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux/
    mv packages/termuxtemp/sshyp-mfa_"$version"-"$revision"_all_termux.deb packages/
    rm -rf packages/termuxtemp
    echo -e "\nTermux packaging complete.\n"
fi

if [ "$distro" == "3" ] || [ "$distro" == "4" ] || [ "$distro" == "6" ] || [ "$distro" == "7" ] || [ "$distro" == "8" ]; then
    echo -e '\nPackaging as generic...\n'
    mkdir -p packages/generictemp/usr/share/man/man1
    cp -r bin packages/generictemp/usr/
    ln -s /usr/bin/sshyp-mfa.py packages/generictemp/usr/bin/sshyp-mfa
    cp -r share packages/generictemp/usr/
    cp extra/manpage packages/generictemp/usr/share/man/man1/sshyp-mfa.1
    gzip packages/generictemp/usr/share/man/man1/sshyp-mfa.1
    tar -C packages/generictemp -cvf packages/sshyp-mfa-"$version".tar.xz usr/
    rm -rf packages/generictemp
    sha512="$(sha512sum packages/sshyp-mfa-"$version".tar.xz | awk '{print $1;}')"
    echo -e "\nsha512 sum:\n$sha512"
    echo -e "\nGeneric packaging complete.\n"
fi

if [ "$distro" == "3" ]; then
    echo -e '\nPackaging for Fedora...\n'
    rm -rf ~/rpmbuild
    rpmdev-setuptree
    cp packages/sshyp-mfa-"$version".tar.xz ~/rpmbuild/SOURCES
    echo "Name:           sshyp-mfa
Version:        "$version"
Release:        "$revision"
Summary:        An MFA (TOTP/Steam) key generator for the sshyp password manager
BuildArch:      noarch

License:        GPLv3
URL:            https://github.com/rwinkhart/sshyp-labs
Source0:        sshyp-mfa-"$version".tar.xz

Requires:       sshyp python

%description
sshyp-mfa is an extension for the sshyp password manager that reads MFA data from sshyp entries and generates generic TOTP and Steam keys.

%install
tar xf %{_sourcedir}/sshyp-mfa-"$version".tar.xz -C %{_sourcedir}
cp -r %{_sourcedir}/usr %{buildroot}

%files
/usr/bin/sshyp-mfa
/usr/bin/sshyp-mfa.py
%license /usr/share/licenses/sshyp-mfa/license
%doc /usr/share/man/man1/sshyp-mfa.1.gz
" > ~/rpmbuild/SPECS/sshyp-mfa.spec
rpmbuild -bb ~/rpmbuild/SPECS/sshyp-mfa.spec
mv ~/rpmbuild/RPMS/noarch/* packages/
rm -rf ~/rpmbuild
echo -e "\nFedora packaging complete.\n"
fi

if [ "$distro" == "4" ] || [ "$distro" == "8" ]; then
    echo -e '\nPackaging for FreeBSD...\n'
    mkdir -p packages/FreeBSDtemp/bin
    tar xf packages/sshyp-mfa-"$version".tar.xz -C packages/FreeBSDtemp
    ln -s /usr/local/bin/python3 packages/FreeBSDtemp/bin/python3
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
                   \"python\" : {
                      \"origin\" : \"lang/python\"
                   },
                },
" > packages/FreeBSDtemp/+MANIFEST
echo "/bin/python3
/usr/bin/sshyp-mfa
/usr/bin/sshyp-mfa.py
/usr/share/licenses/sshyp-mfa/license
/usr/share/man/man1/sshyp-mfa.1.gz
" > packages/FreeBSDtemp/plist
pkg create -m packages/FreeBSDtemp/ -r packages/FreeBSDtemp/ -p packages/FreeBSDtemp/plist -o packages/
rm -rf packages/FreeBSDtemp
echo -e "\nFreeBSD packaging complete.\n"
fi

if [ "$distro" == "7" ] || [ "$distro" == "8" ]; then
    echo -e '\nGenerating PKGBUILD...'
    echo "# Maintainer: Randall Winkhart <idgr at tutanota dot com>

pkgname=sshyp-mfa
pkgver="$version"
pkgrel="$revision"
pkgdesc='An MFA (TOTP/Steam) key generator for the sshyp password manager'
url='https://github.com/rwinkhart/sshyp-labs'
arch=('any')
license=('GPL3')
depends=(sshyp python)

source=(\""$source"\")
sha512sums=('"$sha512"')

package() {

    tar xf sshyp-mfa-"\"\$pkgver\"".tar.xz -C "\"\${pkgdir}\""

}
" > packages/PKGBUILD
    echo -e "\nPKGBUILD generated.\n"
fi
