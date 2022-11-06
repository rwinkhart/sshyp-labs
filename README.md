# sshyp-labs
Experimental extensions for the sshyp password manager.

sshyp-labs is currently the home of sshyp-mfa, and soon to be the home of password-pasture (sshyp-gui).

# Available Extensions
sshyp-mfa - [installation and usage instructions](https://github.com/rwinkhart/sshyp-labs/wiki/sshyp-mfa)

sshyp-mfa is a unique approach to generating multi-factor authentication keys. Upon running `sshyp-mfa <target entry>`,
an MFA key will be generated and copied to your clipboard. sshyp-mfa will continue to run in the background and copy a
new key to your clipboard every time the actively copied one expires. Never worry about a TOTP timer expiring, again!
At any time, sshyp-mfa can be closed with ctrl+c to stop this process.

# Acknowledgements
sshyp-mfa relies on [ValvePython/steam](https://github.com/ValvePython/steam) for Steam support.

sshyp-mfa's TOTP support is partially derrived from [susam/mintotp](https://github.com/susam/mintotp).
