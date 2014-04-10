#!/usr/bin/env python
# -*- coding: utf-8 -*-

from jinja2 import Environment, FileSystemLoader
import sys, os

if sys.version_info < (3, 0):
    reload(sys)
    sys.setdefaultencoding('utf8')
else:
    raw_input = input


env = Environment(loader=FileSystemLoader(os.path.dirname(sys.argv[1])))
template = env.get_template(os.path.basename(sys.argv[1]))
print template.render()