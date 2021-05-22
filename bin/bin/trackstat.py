#!/usr/bin/env python
# -*- coding: utf-8 -*-

import glob
import logging
import os
import subprocess
import sys

def usage(prg_name):
    print('Usage: ' + prg_name + ' trackstatdir')


def main(argv):

    # Configuration du logger
    logging.basicConfig(format='%(levelname)s:%(message)s', 
            level=logging.DEBUG)

    # Verification des arguments
    if len(argv) != 2:
        usage(argv[0])
        return

    # L'argument
    directory = argv[1]
    if directory.endswith('/'):
        directory = directory[:-1]

    # On verifie que l'argument soit bien un repertoire
    if not os.path.isdir(directory):
        logging.critical(directory + ' is not a directory');
        return

    # On itere sur les fichiers
    for filename in os.listdir(directory):
        if filename.endswith('.xml'):
            fullname = directory + '/' + filename
            logging.info('Compressing ' + fullname)
            subprocess.check_call(['gzip', fullname])

    # On recupere la liste des fichiers
    files = glob.glob(directory + '/*.gz')

    # On trie les fichiers
    files = sorted(files)

    # On enleve les 10 derniers ce sont les plus recents
    if len(files) > 10:
        files = files[:-10]

    # On supprime tous les autres fichiers
    for filename in files:
        logging.info('Suppression ' + filename)
        os.unlink(filename)


if __name__ == '__main__':

    main(sys.argv)
