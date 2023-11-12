###How to generate animations:

1. Enable plot and figures saving in main.lua:  

    PLOT = true
    plot_method = Plot.figure

2. Clean figures dir and run algorithm:

    rm figures/*.png && lua main.lua

3. Generate animations using Imagick:

    cd figures/ && convert -delay 50 -loop 0 $(ls -v *.png) animation.mp4

