#!/bin/sh
./cold_collapse.rb -n 10 -s 1 | ./shift.rb -r "[-3,0,0]" > gal1
./cold_collapse.rb -n 10 -s 2 | ./shift.rb -r "[3,0,0]" > gal2
# original
cat gal1 gal2 | ./add_body.rb | ./nbody_sh1.rb -g leapfrog -f -e 0.1 -c 0.02 -t 100 | ./display.rb
# for test
#cat gal1 gal2 | ./add_body.rb | ./nbody_sh1.rb -g leapfrog -e 0.1 -c 0.02 -t 1 > gal0
#cat gal1 gal2 | ./add_body.rb | ./nbody_sh1.rb -g leapfrog -e 0.1 -c 0.002 -t 1 > gal00

# ffmpeg -r 1 -i "galaxy_collision%04d.png" -vcodec mjpeg -sameq galaxy_collision.avi
