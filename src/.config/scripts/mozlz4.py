#!/usr/bin/env python3
# https://unix.stackexchange.com/questions/326897/
# By Hakon A. Hjortland

#Usage:
#mozlz4 -d <previous.jsonlz4 >previous.json
#mozlz4 -c <previous.json >previous.jsonlz4

from sys import *
import os
try:
    import lz4.block as lz4
except ImportError:
    import lz4

stdin = os.fdopen(stdin.fileno(), 'rb')
stdout = os.fdopen(stdout.fileno(), 'wb')

if argv[1:] == ['-c']:
    stdout.write(b'mozLz40\0' + lz4.compress(stdin.read()))
elif argv[1:] == ['-d']:
    assert stdin.read(8) == b'mozLz40\0'
    stdout.write(lz4.decompress(stdin.read()))
else:
    stderr.write('Usage: %s -c|-d <infile >outfile\n' % argv[0])
    stderr.write('Compress or decompress Mozilla-flavor LZ4 files.\n')
    exit(1)

