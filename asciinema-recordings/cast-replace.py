#! /usr/bin/env python

import sys
import json

if len(sys.argv) < 4:
    print("Usage: {} <recording.cast> <string-to-replace> <replacement-string>")
    sys.exit(1) 

cast_file = sys.argv[1]
to_replace = sys.argv[2]
replacement = sys.argv[3]

newlines = []
with open(cast_file, "r") as f:
    header = f.readline()
    newlines.append(header)
    for line in f:
        cmd = json.loads(line)
        cmd[2] = cmd[2].replace(to_replace, replacement)
        newlines.append(json.dumps(cmd) + "\n")

with (open(cast_file, "w")) as f:
    for line in newlines:
        f.write(line)
