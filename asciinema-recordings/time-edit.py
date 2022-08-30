#! /usr/bin/env python

import json
import select
import sys
import tty
import termios
from datetime import datetime
from time import sleep

class NonBlockingConsole(object):

    def __enter__(self):
        self.old_settings = termios.tcgetattr(sys.stdin)
        tty.setcbreak(sys.stdin.fileno())
        return self

    def __exit__(self, type, value, traceback):
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, self.old_settings)


    def get_data(self):
        if select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], []):
            return sys.stdin.read(1)
        return False

if len(sys.argv) < 3:
    print("Usage: {} <recording.cast> <new_recording.cast")
    sys.exit(1) 

cast_file = sys.argv[1]
dest_file = sys.argv[2]

new_cmds = []
last_time = 0
pause = False
start = datetime.now().timestamp()

with NonBlockingConsole() as nbc:
    with open(cast_file, "r") as f:
        header = f.readline()
        for line in f:
            cmd = json.loads(line)
            time_to_wait = cmd[0] - last_time
            
            if time_to_wait > 0.5:
                print("")
                while time_to_wait > 0.1:
                    print("\r", end="")
                    print("Waiting for {:.1f}s (Enter to skip, Space to pause/unpause)      ".format(time_to_wait), end="")
                    sleep(0.1)
                    if not pause: 
                        time_to_wait -= 0.1
                    key = nbc.get_data()
                    if key == ' ':
                        pause = not pause
                    elif key == '\n':
                        break
                print("")
            else:
                sleep(time_to_wait)

            last_time = cmd[0]

            print(cmd[2],end="")
            new_cmds.append([round(datetime.now().timestamp() - start, 6), cmd[1], cmd[2]])

with (open(dest_file, "w")) as f:
    f.write(header)
    for line in new_cmds:
        f.write(json.dumps(line) + "\n")
