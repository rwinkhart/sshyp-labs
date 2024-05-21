#!/usr/bin/env python3

from os import path, remove, system, walk
from pathlib import Path
from shutil import rmtree
from sshyp import decrypt

if __name__ == "__main__":
    _pasture = path.expanduser('~/.local/share/sshyp')
    
    _gpg_id = input('\nWhat is the ID of the GPG key you would like to use for re-encryption?\n\nID: ')

    # remove previous export if it exists
    if Path(f"{_pasture}.export").exists():
        rmtree(f"{_pasture}.export")

    # prompt for unlock and display do not close warning
    decrypt(None)
    print('\nentry conversion may take some time (especially on slower devices) - do not terminate this process!\n')

    # iterate over entires, exporting them in the libmutton format
    if path.isdir(_pasture):
        for _dirPath, _dirNames, _filenames in walk(_pasture):
            for _filename in sorted(_filenames):
                # ensure parent directory within export tree exists
                Path(_dirPath.replace(_pasture, _pasture + '.export')).mkdir(0o700, parents=True, exist_ok=True)

                # remove the .gpg file extension, if it is present
                # prevents saving with the extension, as libmutton does not require it
                _og_extension = ''
                if _filename.endswith('.gpg'):
                    _og_extension = '.gpg'
                    _filename = _filename[:-4]

                # decrypt to export directory, append .gpg to decrypted file to differentiate from new file
                system(f"gpg -d '{_dirPath}/{_filename}{_og_extension}' > '{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg'")

                _old_contents, _new_contents = open(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg", 'r').readlines(), ''

                # extract sshyp-mfa data for new reserved line
                _secret = '\n'
                if len(_old_contents) >= 5:
                    if _old_contents[4].startswith('otpauth://'):
                        # check if sshyp-mfa data is standard TOTP or Steam
                        if _old_contents[4][10:].startswith('steam'):
                            print("\n\u001b[38;5;3mlibmutton uses a different form of secret key for Steam, and as such, your Steam TOTP secret must be migrated manually\u001b[0m\n")
                        else:
                            # extract TOTP secret
                            _secret = _old_contents[4].split('?secret=')[1].split('&issuer=')[0]+'\n'

                # temporarily expand _old_contents to avoid index errors (will be trimmed later)
                while len(_old_contents) < 6:
                    _old_contents.append('\n')

                # extract any possible notes from _old_contents (as a string)
                if _secret == '\n':
                    _old_notes = ''.join(_old_contents[3:])
                else:
                    # skip second notes line if sshyp-mfa data was found
                    # skip first notes line if blank line
                    if _old_contents[3] in ('\n', ' '):
                        _old_contents[3] = ''
                    _old_notes = _old_contents[3] + ''.join(_old_contents[5:])

                # set _new_contents
                _new_contents = _old_contents[0] + _old_contents[1] + _secret + _old_contents[2] + _old_notes

                # remove any trailing whitespace
                for _num in reversed(range(len(_new_contents))):
                    if _new_contents[_num] in ('\n', '', ' '):
                        _new_contents = _new_contents[:-1]
                    else:
                        break

                # write and encrypt the output file
                open(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg", 'w').writelines(_new_contents)
                system(f"gpg -er {str(_gpg_id)} -o '{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}' '{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg'")
                remove(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg")
    else:
        print(f"\n\u001b[38;5;9merror: no entry folder ({_pasture}) found\u001b[0m\n")
        s_exit(2)

