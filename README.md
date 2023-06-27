# sshyp-labs
Extensions for the [sshyp password manager](https://github.com/rwinkhart/sshyp).

When new functionality is desired that goes outside of sshyp's primary goals or requires venturing outside of the Python standard library, said functionality is implemented as an extension.

# Installation
For sshyp v1.5.0+, sshyp extensions should be installed from the `sshyp tweak` menu's "extension management" option.

**Do NOT use the packages from the releases page! These are only for older, unsupported releases of sshyp!**

# Available Extensions
[sshyp-mfa](https://github.com/rwinkhart/sshyp-labs/wiki/sshyp-mfa): read mfa data from sshyp entries to generate and copy totp keys to the clipboard (optional Steam support)

[password-pasture](https://github.com/rwinkhart/sshyp-labs/wiki/password-pasture): a HIGHLY experimental GTK4 sshyp GUI - very incomplete (last updated for sshyp v1.1.x)

# Acknowledgements
sshyp-mfa relies on [ValvePython/steam](https://github.com/ValvePython/steam) for Steam support.

sshyp-mfa's TOTP support is partially derrived from [susam/mintotp](https://github.com/susam/mintotp).
