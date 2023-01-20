#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# vim: set ts=4 ai :
#
# $Id: patch.py $
# $Author: assinie <github@assinie.info> $
# $Date: 2018-11-11 $
# $Revision: 0.1 $
#
# ------------------------------------------------------------------------------

from __future__ import print_function

import os
import sys
import argparse

import struct

# ------------------------------------------------------------------------------
__program_name__ = 'patch'
__description__ = "Patch ROM file"
__plugin_type__ = 'TOOL'
__version__ = '0.3'

# ------------------------------------------------------------------------------


def eprint(*args, **kwargs):
            print(*args, file=sys.stderr, **kwargs)


# ------------------------------------------------------------------------------
def load_rom(fname):
    rom_fn = os.path.abspath(fname)
    with open(rom_fn, 'rb') as fd:
        rom = fd.read()

    if isinstance(rom, str):
        rom = map(ord, rom)
    else:
        # Python 3.x
        rom = [b for b in rom]

    return rom


def patch_rom(fname, rom, base):
    rom_len = len(rom)
    patch_nb = 1
    patch_fn = os.path.abspath(fname)

    with open(patch_fn, 'rb') as fd:
        fd.seek(0, 2)
        flen = fd.tell()
        fd.seek(0, 0)

        i = 0
        while i < flen:
            addr = struct.unpack('<H', fd.read(2))[0]
            #length = ord(fd.read(1))
            #i += 3
            length = struct.unpack('<H', fd.read(2))[0]
            i += 4

            #eprint('Address: 0x%04.4x' % addr)
            #eprint('Length : 0x%04.4x\n' % length)

            patch = fd.read(length)
            if isinstance(patch, str):
                patch = map(ord, patch)
            else:
                # Python 3.x
                patch = [b for b in patch]

            if addr < base or addr-base+length > rom_len:
                eprint('Error: out of range (patch=%d, base=0x%04.4x, addr=0x%04.4x, length=0x%02.2x))' % (patch_nb, base, addr, length))
                sys.exit(1)

            rom[addr-base: addr - base + length] = patch

            patch_nb += 1
            i += length

        return rom


def main():
    parser = argparse.ArgumentParser(prog=__program_name__, description=__description__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--patch', '-p', required=True, type=str, default=None, help='Patch filename')
    parser.add_argument('--rom', '-f', required=True, type=str, default=None, help='ROM filename')
    parser.add_argument('--output', '-o', required=False, type=str, default=None, help='output filename')
    parser.add_argument('--base', '-b', required=False, type=str, default='0xc000', help='Base address for ROM file')
    parser.add_argument('--verbose', '-v', action='count', default=0, help='increase verbosity')
    parser.add_argument('--version', '-V', action='version', version='%%(prog)s v%s' % __version__)

    args = parser.parse_args()

    env_var = os.environ.get(__program_name__.upper() + '_PATH')

    if args.verbose:
        eprint('')
        eprint('Patch  file : ', args.patch)
        eprint('Input  file : ', args.rom)
        eprint('Base Address: ', args.base)
        eprint('Output file : ', args.output)
        eprint('')

    rom = load_rom(args.rom)
    rom = patch_rom(args.patch, rom, int(args.base, 0))

    # rom = ''.join(map(chr, rom))
    if args.output is None:
        rom = ''.join(map(chr, rom))
        print(rom, end='')
    else:
        with open(args.output, 'wb') as fd:
            if sys.version_info.major < 3:
                fd.write(rom)
            else:
                fd.write(bytes(rom))


# -----------------------------------------------------------------------------

if __name__ == '__main__':
    main()
