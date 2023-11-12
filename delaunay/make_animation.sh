#!/bin/bash
rm figures/*.png ; lua main.lua && cd figures/ && convert -delay 50 -loop 0 $(ls -v *.png) animation.mp4 && cd ..
echo "Animation created in figures/animation.mp4"