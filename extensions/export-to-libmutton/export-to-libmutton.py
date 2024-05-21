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
                if _filename.endswith('.gpg'):
                    _filename = _filename[:-4]

                # decrypt to export directory, append .gpg to decrypted file to differentiate from new file
                system(f"gpg -d '{_dirPath}/{_filename}.gpg' > '{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg'")

                _old_contents, _new_contents = open(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}.gpg", 'r').readlines(), ''
                _old_contents_length = len(_old_contents)

                # extract sshyp-mfa data for new reserved line
                if _old_contents_length >= 5:
                    if _old_contents[4].startswith('otpauth://'):
                        # check if sshyp-mfa data is standard TOTP or Steam
                        if _old_contents[4][10:].startswith('steam'):
                            print("\n\u001b[38;5;3mlibmutton uses a different form of secret key for Steam, and as such, your Steam TOTP secret will not be migrated\u001b[0m\n")
                            _secret = '\n'
                        else:
                            # extract TOTP secret
                            _secret = _old_contents[4].split('?secret=')[1].split('&issuer=')[0]+'\n'
                    else:
                        _secret = '\n'

                # add a new line reserved for libmutton's TOTP support (between username and URL)
                for _num in range(len(_old_contents)):
                    if _num == 0:               
                        _new_contents += _old_contents[0] 
                    elif _num == 1:
                        _new_contents += _old_contents[1]
                    elif _num == 2:
                        _new_contents += _secret
                    elif _num == 3:
                        _new_contents += _old_contents[2]
                    elif _num == 4:
                        # append as normal notes line if no sshyp-mfa data was found
                        if _secret == '\n':
                            _new_contents += _old_contents[_num]
                    else:
                        _new_contents += _old_contents[_num]

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

