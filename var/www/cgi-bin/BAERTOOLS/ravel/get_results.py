#!/usr/bin/python3

import cgi
from os.path import join as _join
from os.path import split as _split
from os.path import exists

# Create instance of FieldStorage
form = cgi.FieldStorage()

# Get data from fields
if "fn" in form:
    name = form.getvalue("fn")
else:
    name = None

print("Content-type: text/plain")


if name:
    path = _join('working', name)
    if exists(path):
        with open(path) as fp:
            txt = fp.read()
            print(txt)
    else:
        print(f'Error: path not found  {path}')
else:
    print(f'fn not specified')
