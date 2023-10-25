#!/usr/bin/env python3
from base64 import b32decode
from configparser import ConfigParser
from hmac import new as hmac_new
from os import environ, listdir, uname
from os.path import expanduser, isdir, isfile
from sshyp import decrypt, whitelist_verify
from struct import pack, unpack
from subprocess import PIPE, Popen, run
from sys import argv, exit as s_exit
from time import sleep, strftime, time
home = expanduser("~")


def totp(_secret, _algo, _digits, _period):  # uses provided information to generate a standard totp key
    _secret = b32decode(_secret.upper() + '=' * ((8 - len(_secret)) % 8))
    _counter = pack('>Q', int(time() / _period))
    _hmac = hmac_new(_secret, _counter, _algo).digest()
    _offset = _hmac[-1] & 0x0f
    _binary = unpack('>L', _hmac[_offset:_offset + 4])[0] & 0x7fffffff
    return str(_binary)[-_digits:].zfill(_digits)


def steam_otp(_secret):  # uses provided information to generate a Steam-compatible otp
    _hmac = hmac_new(bytes(_secret), msg=pack('>Q', int(time()//30)), digestmod='sha1').digest()
    _start = ord(_hmac[19:20]) & 0xF
    _codeint = unpack('>I', _hmac[_start:_start+4])[0] & 0x7fffffff
    _charset = '23456789BCDFGHJKMNPQRTVWXY'
    _code = ''
    for _ in range(5):
        _codeint, _i = divmod(_codeint, len(_charset))
        _code += _charset[_i]
    return _code


def mfa_read_shortcut():  # extracts MFA info from the user-specified sshyp entry
    if not isfile(f"{directory}{arguments[0]}.gpg"):
        print(f"\n\u001b[38;5;9merror: entry ({arguments[0]}) does not exist\u001b[0m\n")
        s_exit(1)
    if quick_unlock_enabled:
        _mfa_data = decrypt(directory + arguments[0],
                            _quick_pass=whitelist_verify(sshyp_data.get('SSHYNC', 'port'),
                                                         sshyp_data.get('SSHYNC', 'user'),
                                                         sshyp_data.get('SSHYNC', 'ip'),
                                                         listdir(f"{home}/.config/sshyp/devices")[0],
                                                         sshyp_data.get('SSHYNC', 'identity_file')))
    else:
        _mfa_data = decrypt(directory + arguments[0])
    try:
        _type = _mfa_data[4].split('otpauth://')[1].split('/')[0]
        _secret = _mfa_data[4].split('?secret=')[1].split('&issuer=')[0]
        _algo = _mfa_data[4].split('&algorithm=')[1].split('&digits=')[0]
        _digits = int(_mfa_data[4].split('&digits=')[1].split('&period=')[0])
        _period = int(_mfa_data[4].split('&period=')[1])
        return _type, _secret, _algo, _digits, _period
    except IndexError:
        print(f"\n\u001b[38;5;9merror: entry ({arguments[0]}) does not contain valid mfa data\u001b[0m\n")
        s_exit(1)


if __name__ == '__main__':
    # argument fetcher
    arguments = argv[1:]
    if len(arguments) < 1 or not arguments[0].startswith('/'):
        print("\nsshyp-mfa extension usage: sshyp </entry name> copy -m\n\nrun 'man sshyp-mfa' for more information\n")
        s_exit(1)

    # user data fetcher
    sshyp_data = ConfigParser()
    sshyp_data.read(f"{home}/.config/sshyp/sshyp.ini")
    directory = f"{home}/.local/share/sshyp/"
    quick_unlock_enabled = sshyp_data.getboolean('CLIENT-ONLINE', 'quick_unlock_enabled')

    # main process: runs functions to generate MFA key, then continuously copies up-to-date MFA key to clipboard
    try:
        mfa_data, copied = mfa_read_shortcut(), None
        print('\nmfa key copied to clipboard\n\nuntil this process is closed, your clipboard will be automatically '
              'updated with the newest mfa key')
        while True:
            if str(int(strftime('%S'))/mfa_data[4]).endswith('.0') or copied is None:
                if copied is None:
                    copied = 1
                if mfa_data[0] == 'steam':
                    _mfa_key = steam_otp(b32decode(mfa_data[1]))
                else:
                    _mfa_key = totp(mfa_data[1], mfa_data[2], mfa_data[3], mfa_data[4])
                if 'WSL_DISTRO_NAME' in environ:  # WSL clipboard detection
                    run(('powershell.exe', '-c', "Set-Clipboard '" + _mfa_key + "'"))
                elif 'WAYLAND_DISPLAY' in environ:  # Wayland clipboard detection
                    run('wl-copy', stdin=Popen(('printf', _mfa_key), stdout=PIPE).stdout)
                elif uname()[0] == 'Haiku':  # Haiku clipboard detection
                    run(('clipboard', '-c', _mfa_key))
                elif uname()[0] == 'Darwin':  # MacOS clipboard detection
                    run('pbcopy', stdin=Popen(('printf', _mfa_key), stdout=PIPE).stdout)
                elif isdir("/data/data/com.termux"):  # Termux (Android) clipboard detection
                    run(('termux-clipboard-set', _mfa_key))
                else:  # X11 clipboard detection
                    run(('xclip', '-sel', 'c'), stdin=Popen(('printf', _mfa_key), stdout=PIPE).stdout)
            sleep(1)
    except KeyboardInterrupt:
        s_exit(0)
