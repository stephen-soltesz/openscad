use <cutholes.scad>;

// Badge dimensions.
badge_width = 55;  // mm.
badge_height = 86;  // mm.
badge_depth = 2.5;  // mm. thickness of badge.

// Shapeways model tolerance.
// Stainless steel edges must be at least 1.5 mm thick.
tolerance = 1.5; // mm.

// The cover height is the size of each top and bottom "bands" of the badge.
cover_height = 11; // mm.

// Dimensions are built up around three shapes: outside, slot, and window.
// Outside dimensions define the external size of the entire frame.  Slot
// dimensions define the inner gap where the badge will slide into frame.
// Window dimensions define the empty area in the frame where the badge is
// visible.

// Depths.
slot_depth = badge_depth + 0.5;  // pretty tight on front & back of badge.
outside_depth = slot_depth + 2*tolerance;  // the minimum steel wall size.
window_depth = outside_depth + 0.1;  // same as outside + precision error.

// Widths.
slot_width = badge_width + 0.5;  // pretty tight on left & right.
// To hold badge in place, the window should be *smaller* than the actual
// badge. Frame will cover left & right badge edges by 'tolerance' mm.
window_width = badge_width - 2*tolerance;
// Add tolerance to left & right plus additional padding (.75) for volume lost
// by the beveled edges.
outside_width = slot_width + 2*tolerance + 2.0;


// Heights. Heights are assigned in two steps. The first step assigns minimum
// heights based on the badge height and manufacturing tolerances. The second
// step "stretches" the heights to make room to bore a hole through the top
// cover. The heights are "stretched" enough to place the top of the badge
// below the hole.

// First step: minimum slot, window, & outside height.
slot_height_pre = badge_height + 0.5;
// Add extra padding (1) is for volume lost on the bottom beveled edge.
outside_height_pre = slot_height_pre + 2*tolerance + 1;
// The window height is what remains between the 'covers' on top & bottom.
window_height_pre = outside_height_pre - 2*cover_height;

// Second step: "stretch" heights calculated above to make room for hole.
stretch_height = (
    cover_height - tolerance - (outside_height_pre - slot_height_pre)/2);
slot_height = slot_height_pre; //  + stretch_height - tolerance;
outside_height = outside_height_pre + stretch_height;
window_height = window_height_pre + stretch_height;


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

// The capmask creates a block shape that will be used to take the
// difference and union of a full badge shape. The difference will
// cut-away a hole, and the union will create a free-form cap.
module capmask(tab_width, tab_height, tab_depth,
               mask_width, mask_height, mask_depth)
{
  translate([0, -mask_height, 0])
  union() {
    translate([0, -tab_height/2, 0])
      cube(size=[tab_width,tab_height,tab_depth], center=true);
    translate([0, mask_height/2, 0])
        cube(size=[mask_width,mask_height,mask_depth], center=true);
  }
}


// The badge consists of three intersecting shapes.
// 1) The 'beveledcube' defines the volume of the entire frame.
// 2) The 'cylindercube' creates the window by subtracting it from the
//    badge frame to create a portal to view the badge.
// 3) The slot cube is subtracted from within the badgeframe to
//    create a space for the badge to fit.


module badge(outside_width, outside_height, outside_depth) {
  difference() {
    // outside frame.
    beveledcube(outside_width, outside_height, outside_depth);

    // cut out the viewing window from the center.
    translate([0,0,0])
      cylindercube(window_width, window_height, window_depth);

    // cut out the slot within the frame.
    translate([0,-(stretch_height-tolerance)/2,0])
    cube(size = [slot_width,slot_height,slot_depth], center = true);

    // finish cutting the slot through the rest of the badge clip.
//    translate([0,-stretch_height/2,0])
//      cube(size = [slot_width,slot_height,slot_depth], center = true);
  }
}


// Create the badge, center top badge cover above the origin, and 
// cut a donut hole through it.

hole_offset = cover_height/2 + 1; // cover_height-1; // 3*cover_height/4+3;
hole_size = 5;

translate([0, 10, 0]) {
  intersection(){
    translate([0, -(hole_offset), 0])
     circlehole(hole_size, hole_size, outside_depth)
      difference() {
        translate([0, -outside_height/2+hole_offset, 0])
          badge(outside_width, outside_height, outside_depth);
        //cylinder(h=outside_depth, r=3, center=true, $fs=0.01);
        //cube(size=[6, 6, outside_depth], center=true);
      }

    color("pink")
      capmask(slot_width-0.1,
            cover_height-outside_depth/2-tolerance-0.24,
            slot_depth-0.1,
            outside_width, outside_depth/2, outside_depth);

  }
}

difference() {

  translate([0, -(hole_offset), 0])
  difference() {
    circlehole(hole_size, hole_size, outside_depth)
      translate([0, -outside_height/2+hole_offset, 0])
        badge(outside_width, outside_height, outside_depth);

    // "Rulers" used during testing.
    translate([20, -outside_height/2+hole_offset-1, 0])   
      cube(size=[outside_width/2, outside_height, outside_depth], center=true);
  }

  color("pink")
    capmask(slot_width, cover_height-outside_depth/2-tolerance-0.24, slot_depth,
      outside_width, outside_depth/2, outside_depth-0.1);
}

translate([-25, -badge_height/2 - 2.5 -(cover_height/2+1), 0])
  color("lightblue")
    cube(size=[badge_width,badge_height,badge_depth], center=true);
//translate([5, -outside_height+13.5, 0])
//  color("pink")
//    cube(size=[tolerance,8,badge_depth], center=true);
//translate([5, 0.875, 0])
//  color("pink")
//    cube(size=[tolerance,10.5,badge_depth], center=true);
