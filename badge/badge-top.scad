use <cutholes.scad>;

// Badge dimensions.
badge_width = 55;  // mm.
badge_height = 86;  // mm.
badge_depth = 2.5;  // mm. thickness of badge.

// Shapeways model tolerance.
// Stainless steel edges must be at least 1.5 mm thick.
tolerance = 1.5; // mm.

// Window is the empty area that makes the badge visible. To hold badge in
// place the window should be *smaller* than the actual badge dimensions.
// Cover left & right, and top & bottom by 'tolerance' mm.
window_width = badge_width - 2*tolerance;
window_height = badge_height - 5*tolerance;
// window_depth is assigned below.

// Slot is the inner gap where the badge will slide into frame.
// The slot should be *slightly* larger than the badge.
// Add 1mm on left & right, and top & bottom. (does not include badge clip).
slot_width = badge_width + 2;
slot_height = badge_height + 1 + 2*tolerance;
slot_depth = badge_depth + 1;  // pretty tight. but should be enought.

// Outside is the external dimension of the entire frame.
// The additional padding (.75) is for volume lost by the beveled edges.
// Add tolerance on left & right, top & bottom.
outside_width = slot_width + 2*tolerance + 0.75;
outside_height = slot_height + 7*tolerance + 0.75;
outside_depth = slot_depth + 2*tolerance;  // the bare minimum wall size.

// Now that we have defined outside_depth, we can assign window_depth.
// Make window_depth a little larger to guarantee a complete removal of frame
// without aliasing due to floating point precision.
window_depth = outside_depth + 0.1;

// The badge also has a clip on top. This is the height of the clip.
clip_height = outside_height/15;
// clip_height = (outside_width - window_width) / 2 + 1;


// Creates a "beveled cube" of dimensions width x height x depth with beveled
// edges of radius depth/2. All dimensions are preserved, but volume is less
// due to beveled edges. The entire shape is centered at the origin: 0, 0, 0.
module beveledcube(width, height, depth) {
  r = depth/2;
  // Set local w and h so that given width and height are preserved.
  w = width - depth;  // radius will be added twice on left and right.
  h = height - depth;  // radius will be added twice on top and bottom.

  // creates a convex hull around these four spheres.
  hull() {
    translate([-w/2, -h/2, 0]) sphere(r, $fs=0.01);
    translate([ w/2, -h/2, 0]) sphere(r, $fs=0.01);
    translate([-w/2,  h/2, 0]) sphere(r, $fs=0.01);
    translate([ w/2,  h/2, 0]) sphere(r, $fs=0.01);
  }
}

// Creates a "cylinder cube" of dimensions width x height x depth with beveled
// edges of radius depth/2 only on the width and height dimensions. All
// dimensions are preserved, but volume is less due to beveled edges. The
// entire shape is centered at the origin: 0, 0, 0.
module cylindercube(width, height, depth) {
  r = depth/2;
  // Set local w and h so that given width and height are preserved.
  w = width - depth;  // radius will be added twice on left and right.
  h = height - depth;  // radius will be added twice on top and bottom.

  // creates a convex hull around these four spheres.
  hull() {
    translate([-w/2, -h/2, 0]) cylinder(h=depth, r=r, center=true, $fs=0.01);
    translate([ w/2, -h/2, 0]) cylinder(h=depth, r=r, center=true, $fs=0.01);
    translate([-w/2,  h/2, 0]) cylinder(h=depth, r=r, center=true, $fs=0.01);
    translate([ w/2,  h/2, 0]) cylinder(h=depth, r=r, center=true, $fs=0.01);
  }
}

// Creates a badge shape with beveled edges and top clip area.
// The top clip will extend clip_height above height, with a hole through the
// middle. 
module badgeframe(width, height, depth, clip_height) {
  difference() {
    union() { 
      // Badge clip on top.
      // Create a smaller beveledcube of clip_height size. Clip height is
      // doubled but only half will extend above frame. The overlap helps blend
      // the two shapes together.
      //translate([0, height/2+clip_height/4, 0])
      //  donuthole(5, 5, 6, 7)
        //roundhole(5, 5, depth, 1)
        //union() {
        //  translate([0, -(clip_height*2+clip_height/4)/2, 0])
        //    cube(size=[width/4, clip_height/4, depth], center=true);
       //  translate([0, -1, 0])
         //  beveledcube(width, clip_height*2, depth);
        //}
      // Badge frame.
      beveledcube(width, height, depth);
    }

    // Cut a hold in the clip, half as large as clip_height.
    // translate([0, height/2+clip_height/5, 0]) {
    //     cube(size=[width/4, clip_height/2, depth], center=true);
    //  }
  } 
}

// Logically, the badge holder consists of three intersecting shapes.
// 1) The 'badgeframe' defines the volume of the entire frame.
// 2) The window cylindercube is subtracted from the badgeframe shape
//    to create a portal to view the badge.
// 3) The slot cube is subtracted from within the badgeframe to
//    create a space for the badge to fit.

module badge(ow, oh, od, ww, wh, wd, sw, sh, sd) {
  difference() {
    // outside shape.
    badgeframe(outside_width+ow, outside_height+oh, outside_depth+od, clip_height);

    // cut out the viewing window from the center.
    cylindercube(window_width+ww, window_height+wh, window_depth+wd);

    // cut out the slot within the frame.
    cube(size = [slot_width+sw,slot_height+sh,slot_depth+sd], center = true);

    // finish cutting the slot through the rest of the badge clip.
    translate([0,20,0])
      cube(size = [slot_width+sw,slot_height+sh,slot_depth+sd], center = true);
  }
}

// normal.
difference() {
  donuthole(5, 5, 7, 7)
    translate([0, -outside_height/2+4*tolerance+1, 0])
      badge(0, 0, 0, 0, 0, 0, 0, 0, 0);

//  translate([20, -outside_height/2+4*tolerance+0.5, 0])   
//    cube(size=[outside_width/2, outside_height, outside_depth], center=true);
}
//translate([-25, -badge_height/2-2*tolerance, 0])
//  color("lightblue")
//    cube(size=[badge_width,badge_height,badge_depth], center=true);


