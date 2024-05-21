#!/usr/bin/env python3

from os import path, remove, system, walk
from pathlib import Path
from shutil import move, rmtree

# NOTE LARGELY UNTESTED, ALPHA EXTENSION
# TODO strip .gpg extension, if present
# TODO extract and move MFA data to dedicated field, if present

if __name__ == "__main__":
    _pasture = path.expanduser('~/.local/share/sshyp')
    
    # set new gpg key; note that this changes sshyp's gpg key, not just libmutton's
    gpg_config()

    # remove previous export if it exists
    if Path(f"{_pasture}.export").exists():
        rmtree(f"{_pasture}.export")

    # prompt for unlock and display do not close warning
    decrypt(None)
    curses_radio(['okay'], 'entry conversion may take some time (especially on slower devices)\n\nselect "okay" '
                           'to start\n\ndo not terminate this process!')

    # iterate over entires, exporting them in the libmutton format
    if path.isdir(_pasture):
        _gpg_id = sshyp_data.get('CLIENT-GENERAL', 'gpg_id')
        for _dirPath, _dirNames, _filenames in walk(_pasture):
            for _filename in sorted(_filenames):
                # ensure parent directory within export tree exists
                Path(dirPath.replace(_pasture, _pasture + '.export')).mkdir(0o700, parents=True, exist_ok=True)

                # manually decrypt due to potential lack of .gpg extension
                system(f"gpg -d '{_dirPath}/{_filename}' > '{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}'")

                _old_contents, _new_contents = open(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}", 'r').readlines(), ''

                # add a new line reserved for libmutton's TOTP support (between username and URL)
                for _num in range(len(_old_contents)):
                    match _num:
                        case 0:               
                            _new_contents += _old_contents[0] 
                        case 1:
                            _new_contents += _old_contents[1]
                        case 2:
                            _new_contents += ''
                        case 3:
                            _new_contents += _old_contents[2]
                        case _:
                            _new_contents += _old_contents[_num]

                # write and manually encrypt the output file
                open(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}", 'w').writelines(_new_contents)
                system(f"gpg -qr {str(_gpg_id)} -e '{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}'")
                remove(f"{_dirPath.replace(_pasture, _pasture + '.export')}/{_filename}")
    else:
        print(f"\n\u001b[38;5;9merror: no entry folder ({_pasture}) found\u001b[0m\n")
        s_exit(2)

