#!/bin/bash
while true
do
    ncat -lvp 4444 < /home/ec2-user/nc_commands.txt 
done
