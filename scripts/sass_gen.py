#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, os, sass
from csscompressor import compress

if sys.version_info < (3, 0):
    reload(sys)
    sys.setdefaultencoding('utf8')
else:
    raw_input = input

file_contents = [open(x, 'r').read() for x in sys.argv[1:]]

print compress(sass.compile_string('\n\n'.join(file_contents)))