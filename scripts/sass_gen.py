#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, os, sass
from csscompressor import compress

if sys.version_info < (3, 0):
    reload(sys)
    sys.setdefaultencoding('utf8')
else:
    raw_input = input

print compress(sass.compile_string(open(sys.argv[1], 'r').read()))