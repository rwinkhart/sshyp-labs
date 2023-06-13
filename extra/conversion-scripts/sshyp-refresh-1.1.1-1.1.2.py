#!/usr/bin/env python3

from os import path, system, uname, walk
from pathlib import Path
from shutil import move, rmtree
from sshyp import decrypt, encrypt, optimized_edit, shm_gen

if __name__ == "__main__":
    directory, tmp_dir = path.expanduser('~/.local/share/sshyp'), path.expanduser('~/.config/sshyp/tmp/')
    if uname()[0] == 'Haiku':  # set proper gpg command for OS
        gpg = 'gpg --pinentry-mode loopback'
    else:
        gpg = 'gpg'
    system(f"{gpg} -k")
    gpg_id = input('\ngpg id for re-encryption: ')
    if Path(f"{directory}.new").exists():
        rmtree(f"{directory}.new")
    if Path(f"{directory}.old").exists():
        rmtree(f"{directory}.old")
    if path.isdir(directory):
        print('\nconverting... please wait, do not force close this process')
        for dirPath, dirNames, filenames in walk(directory):
            for filename in sorted(filenames):
                Path(dirPath.replace(directory, directory + '.new')).mkdir(0o700, parents=True, exist_ok=True)
                _shm_folder, _shm_entry = shm_gen()
                decrypt(f"{dirPath}/{filename[:-4]}", _shm_folder, _shm_entry, gpg)
                _new_lines = optimized_edit(open(f"{tmp_dir}{_shm_folder}/{_shm_entry}", 'r').readlines(), None, -1)
                open(f"{tmp_dir}{_shm_folder}/{_shm_entry}", 'w').writelines(_new_lines)
                encrypt(f"{dirPath.replace(directory, directory + '.new', 1)}/{filename[:-4]}",
                        _shm_folder, _shm_entry, gpg, gpg_id)
        move(directory, f"{directory}.old")
        move(f"{directory}.new", directory)
    else:
        print(f"\nError: no entry folder ({directory}) found\n")
