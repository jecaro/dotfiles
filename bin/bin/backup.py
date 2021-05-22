#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import time
import sys
import subprocess


def main(argv):

    if len(argv) != 3:

        print('Usage: ' + argv[0] + ' dir_to_save where_to_copy')
        return

    dir_to_save = argv[1]
    backup_dir = argv[2]

    # On regarde si le dossier existe lorsqu'on ne travaille pas en ssh
    if '@' not in dir_to_save and not os.path.isdir(dir_to_save):
        print(dir_to_save + ' is not a directory')
        return

    if not os.path.isdir(backup_dir):
        print(backup_dir + ' is not a directory')
        return

    # On prend le chemin absolu si on n'est pas en ssh
    if '@' not in dir_to_save:
        dir_to_save = os.path.abspath(dir_to_save) + '/'
    # On rajoute un slash si besoin
    elif not dir_to_save.endswith('/'):
        dir_to_save = dir_to_save + '/'

    backup_dir = os.path.abspath(backup_dir) + '/'

    log_filename = backup_dir + 'LOG'

    # Getting the last modified directory
    last_dir = None
    last_time = None

    for filename in os.listdir(backup_dir):

        filename = backup_dir + filename

        if not os.path.isdir(filename):
            continue

        modified = os.stat(filename).st_mtime

        if last_time is None or modified > last_time:
            last_time = modified
            last_dir = filename

    # The new directory
    new_dir = backup_dir + 'backup-' + time.strftime("%y%m%d-%H%M%S")

    # Example of command line: 
    # rsync -crltDvh --log-file=LOG --delete --link-dest=/var/run/media/jc/Elements/backup-140731 /home/jc/ /var/run/media/jc/Elements/backup-140822

    # Command line creation
    cmd = ['rsync', '-crltDvh', '--log-file=' + log_filename, '--delete']

    # There is a last directory
    if last_dir is not None:
        cmd.append('--link-dest=' + last_dir)

    # Finalize the command
    cmd.append(dir_to_save)
    cmd.append(new_dir)

    # Launch the command
    print(cmd)
    subprocess.call(cmd)

if __name__ == "__main__":

    main(sys.argv)

