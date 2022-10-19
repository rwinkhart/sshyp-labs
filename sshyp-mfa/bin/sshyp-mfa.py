#!/usr/bin/env python3

from base64 import b32decode
from hmac import new as new_mac
from os import environ, path, system, uname
from pathlib import Path
from shutil import rmtree
from sshync import get_profile
from sshyp import decrypt, entry_list_gen, shm_gen
from struct import pack, unpack
from sys import argv, exit as s_exit
from time import sleep, strftime, time


def totp(_secret, _algo, _digits, _period):  # uses provided information to generate a standard totp key
    _secret = b32decode(_secret.upper() + '=' * ((8 - len(_secret)) % 8))
    _counter = pack('>Q', int(time() / _period))
    _mac = new_mac(_secret, _counter, _algo).digest()
    _offset = _mac[-1] & 0x0f
    _binary = unpack('>L', _mac[_offset:_offset + 4])[0] & 0x7fffffff
    return str(_binary)[-_digits:].zfill(_digits)


def mfa_read_shortcut():  # reads and extracts MFA info from the user-specified sshyp entry
    if not Path(f"{directory}{argument}.gpg").exists():
        print(f"\n\u001b[38;5;9merror: entry ({argument}) does not exist\u001b[0m\n")
        s_exit(1)
    _shm_folder, _shm_entry = shm_gen()
    decrypt(directory + argument, _shm_folder, _shm_entry, gpg, quick_unlock_status)
    try:
        _mfa_data = open(f"{path.expanduser('~/.config/sshyp/tmp/')}{_shm_folder}/{_shm_entry}", 'r').readlines()
        _type = _mfa_data[4].split('otpauth://')[1].split('/')[0]
        _secret = _mfa_data[4].split('?secret=')[1].split('&issuer=')[0]
        _algo = _mfa_data[4].split('&algorithm=')[1].split('&digits=')[0]
        _digits = int(_mfa_data[4].split('&digits=')[1].split('&period=')[0])
        _period = int(_mfa_data[4].split('&period=')[1])
        rmtree(f"{path.expanduser('~/.config/sshyp/tmp/')}{_shm_folder}")
        return _type, _secret, _algo, _digits, _period
    except IndexError:
        print(f"\n\u001b[38;5;9merror: entry ({argument}) does not contain valid mfa data\u001b[0m\n")
        rmtree(f"{path.expanduser('~/.config/sshyp/tmp/')}{_shm_folder}")
        s_exit(1)


if __name__ == '__main__':
    # argument fetcher
    argument_list = argv
    if not len(argv) == 1 and not argv[1].strip().startswith('/'):
        print(f"\n\u001b[38;5;9merror: invalid argument - run 'man sshyp-mfa' for usage information\u001b[0m\n")
        s_exit(1)

    # user data fetcher
    quick_unlock_status = open(path.expanduser('~/.config/sshyp/sshyp-data')).readlines()[3].rstrip()
    ssh_info = get_profile(path.expanduser('~/.config/sshyp/sshyp.sshync'))
    directory = str(ssh_info[3].replace('\n', ''))
    if uname()[0] == 'Haiku':  # set proper gpg command for OS
        gpg = 'gpg --pinentry-mode loopback'
    else:
        gpg = 'gpg'

    # main process; runs functions to generate MFA key, then continuously copies up-to-date MFA key to clipboard
    try:
        if len(argument_list) == 1:
            entry_list_gen()
            argument_list.append(input('entry to read: '))
        argument = ' '.join(argument_list[1:]).replace('/', '', 1)
        mfa_data, copied = mfa_read_shortcut(), None
        print('\nmfa key copied to clipboard\n\nuntil this process is closed, your clipboard will be automatically '
              'updated with the newest mfa key')
        while True:
            if str(int(strftime('%S'))/mfa_data[4]).endswith('.0') or copied is None:
                if copied is None:
                    copied = 1
                if mfa_data[0] == 'steam':
                    from steam.guard import generate_twofactor_code as steam_totp
                    _mfa_key = steam_totp(b32decode(mfa_data[1]))
                else:
                    _mfa_key = totp(mfa_data[1], mfa_data[2], mfa_data[3], mfa_data[4])
                if uname()[0] == 'Haiku':  # Haiku clipboard detection
                    system(f"clipboard -c '{_mfa_key}'")
                elif Path("/data/data/com.termux").exists():  # Termux (Android) clipboard detection
                    system(f"termux-clipboard-set '{_mfa_key}'")
                elif environ.get('WAYLAND_DISPLAY') == 'wayland-0':  # Wayland clipboard detection
                    system(f"wl-copy '{_mfa_key}'")
                else:  # X11 clipboard detection
                    system(f"echo -n '{_mfa_key}' | xclip -sel c")
            sleep(1)
    except KeyboardInterrupt:
        print('\n')
        s_exit(0)
