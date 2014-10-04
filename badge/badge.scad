// g-Badge dimensions.
width = 55;  // mm.
height = 86;  // mm.
depth = 2.5;  // mm.

// Shapeways model tolerance.
// Stainless steel edges must be at least 1.5 mm thick.
tolerance = 1.5; // mm.

// Window is the empty area that makes the badge visible.
// Window should be *smaller* than the actual badge dimensions.
window_width = width - 2*tolerance;  // cover left and right by 'tolerance' mm.
window_height = height - 2*tolerance;  // cover top and bottom by 'tolerance' mm.

// Slot is the inner gap that allows badge to slide into frame.
// The slot should be *slightly* larger than the badge.
slot_width = width + 2;  // 1 mm on left and right.
slot_height = height + 2;  // 1 mm on bottom. top is handled differently due to badge clip.
slot_depth = depth + 0.5;  // pretty tight. but should be enought.

// Outside is the external dimension of the entire frame.
// Must be greater than slot_width.
outside_width = slot_width + 2*tolerance;  // extra 'tolerance' on left & right.
outside_height = slot_height + 2*tolerance; // extra 'tolerance' on bottom and top.
outside_depth = slot_depth + 2*tolerance;  // extra 'tolerance' around inner slot depth.

// Assign window_depth now that we have defined outside_depth.
// Make it a little larger to guarantee a complete removal of frame.
window_depth = outside_depth+0.1;


// Creates a cube of dimensions width, height, depth with beveled edges of radius depth/2.
// The width and height are increased by depth/2.
// The entire shape is centered round 0,0,0 axis.
module roundcube(width, height, depth) {
  delta=depth/3;
  radius=depth/2;
  hull() {
    translate([-width/2+delta, -height/2+delta, 0]) sphere(radius, $fs=0.01);
    translate([ width/2-delta, -height/2+delta, 0]) sphere(radius, $fs=0.01);
    translate([-width/2+delta,  height/2-delta, 0]) sphere(radius, $fs=0.01);
    translate([ width/2-delta,  height/2-delta, 0]) sphere(radius, $fs=0.01);
  }
}

// creates a badge shape with beveled edges and top clip area.
// The top clip will extend clip_height above height, with a hole through the middle. 
module badgeshape(width, height, depth, clip_height) {
  difference() {
    union() { 
      // badge clip on top.
      // roundcube is centered, so make the clip shape twice as large, but only
      // half will extend above frame. The overlap helps blend the two roundcubes together.
      translate([0, height/2, 0]) roundcube(width/2, clip_height*2, depth);
      // badge frame.
      roundcube(width, height, depth);
    }

    // cut a hold in the clip shape half as large as clip_height.
    translate([0, height/2+clip_height/4, 0]) {
        cube(size=[width/4, clip_height/2, depth], center=true);
    }
  } 
}

// Logically, the badge holder consists of three intersecting shapes.
// 1) The outside cube defines the volume of the entire frame.
// 2) The slot cube is subtracted from within the frame to 
//    create a slot for the badge to be inserted.
// 3) The window cube is also subtracted from the outside cube to
//    create a portal to view the badge.

// this is a guess that looks okay.
clip_height = outside_height/15;

difference() {
  // outside shape.
  badgeshape(outside_width, outside_height, outside_depth, clip_height);

  // cut out the viewing window from the center.
  cube(size = [window_width,window_height,window_depth], center = true);

  // cut out the slot within the frame.
  cube(size = [slot_width,slot_height,slot_depth], center = true);

  // finish cutting the slot through the rest of the badge clip.
  translate([0,20,0]) cube(size = [slot_width,slot_height,slot_depth], center = true);
}
