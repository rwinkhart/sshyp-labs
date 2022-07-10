#!/bin/python3

from os import path, remove, system, walk
from pathlib import Path
from shutil import move, rmtree

if __name__ == "__main__":
    gpg_id = input('\nWhat is the ID of the GPG key you would like to use for re-encryption?\n\nID: ')
    directory = path.expanduser('~/.local/share/sshyp')
    if Path(f"{directory}.new").exists():
        rmtree(f"{directory}.new")
    if Path(f"{directory}.old").exists():
        rmtree(f"{directory}.old")
    if path.isdir(directory):
        for dirPath, dirNames, filenames in walk(directory):
            for filename in sorted(filenames):
                Path(dirPath.replace(directory, directory + '.new')).mkdir(0o700, parents=True, exist_ok=True)
                system(f"gpg -d '{dirPath}/{filename}' "
                       f"> '{dirPath.replace(directory, directory + '.new')}/{filename[:-4]}'")
                _old_contents, _new_contents = \
                    open(f"{dirPath.replace(directory, directory + '.new')}/{filename[:-4]}", 'r').readlines(), ''
                for _num in range(len(_old_contents)):
                    if _num == 3:
                        if _old_contents[_num] == ' ' or _old_contents[_num] == '\n':
                            pass
                        else:
                            _new_contents += _old_contents[_num]
                    else:
                        _new_contents += _old_contents[_num]
                for _num in reversed(range(len(_new_contents))):
                    if _new_contents[_num] == '\n' or _new_contents[_num] == '':
                        _new_contents = _new_contents[:-1]
                    else:
                        break
                open(f"{dirPath.replace(directory, directory + '.new')}/{filename[:-4]}", 'w').writelines(_new_contents)
                system(f"gpg -qr {str(gpg_id)} -e '{dirPath.replace(directory, directory + '.new')}/{filename[:-4]}'")
                remove(f"{dirPath.replace(directory, directory + '.new')}/{filename[:-4]}")
    else:
        print(f"\nError: no entry folder ({directory}) found\n")
    move(directory, f"{directory}.old")
    move(f"{directory}.new", directory)
