thickness = 1.5;
width = 15;
height = 80;

cube(size=[width, height, thickness], center=true);

//translate([width/2-thickness/2, 0, thickness/2])
//cube(size=[thickness, height, 2 * thickness], center=true);

translate([0, height/2, thickness/2])
cube(size=[width, thickness, 2 * thickness], center=true);

translate([0, -height/2, thickness/2])
cube(size=[width, thickness, 2 * thickness], center=true);
