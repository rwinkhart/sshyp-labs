# sshyp-labs
Extensions for the [sshyp password manager](https://github.com/rwinkhart/sshyp).

When new functionality is desired that goes outside of sshyp's primary goals or requires venturing outside of the Python standard library, said functionality is implemented as an extension.

# Installation
For most sshyp-supported platforms, sshyp extensions should be installed from the `sshyp tweak` menu's "extension management" option.

For **Haiku and Termux _ONLY_**, use the packages from the [releases page](https://github.com/rwinkhart/sshyp-labs/releases).

# Available Extensions
[sshyp-mfa](https://github.com/rwinkhart/sshyp-labs/wiki/sshyp-mfa): read mfa data from sshyp entries to generate and copy totp keys to the clipboard (includes Steam support)

[password-pasture](https://github.com/rwinkhart/sshyp-labs/wiki/password-pasture): a HIGHLY experimental GTK4 sshyp GUI - very incomplete (last updated for sshyp v1.1.x)

# Acknowledgements
sshyp-mfa's TOTP support is partially derrived from [susam/mintotp](https://github.com/susam/mintotp).

sshyp-mfa's Steam support is partially derrived from [ValvePython/steam](https://github.com/ValvePython/steam).

These packages are _not_ required as dependencies; the necessary code from each is included in sshyp-mfa.
