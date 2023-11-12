
### How to generate animations:

Enable plot and figures saving in main.lua:   

    PLOT = true
    plot_method = Plot.figure

Clean figures dir and run algorithm:

    rm figures/*.png && lua main.lua

Generate animations using Imagick:

    cd figures/ && convert -delay 50 -loop 0 $(ls -v *.png) animation.mp4

