// base plate
color("red")
cube([150,150,0.5],true);
// upside/downside marker

// figure
scale([2,2,1])
linear_extrude(height=1) import("tikzSamples01.svg", center = true, dpi = 960); 
