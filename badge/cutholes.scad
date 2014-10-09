
// roundhole cuts a round beveled hole through x-y plane in a child shape. The
// hole will be scaled to have width, height, and depth dimensions. The scaling
// factor should be greather than 1 and controls the curvature of
// the round hole bevel. 1 is maximum, and greater number is less curvature.
//
// Example usage:
//   roundhole(5, 5, 5, 1.0) cube(size=[20, 20, 20], center=true);
//
module roundhole(width, height, depth, s) {
  radius = depth/2;
  S = (s <= 0 ? 0 : 1/s);
  trans = radius + S*radius;

  difference() {
    children();

    // Create "netagive" form of an hour-glass to subtract from children above.
    scale([width/depth, height/depth, 1]) {
      difference() {
        // create a cylinder and subtract a torus to leave an 'hour-glass' shape.
        cylinder(h=depth, r=depth, center=true);
        rotate_extrude(convexity = 10) {
          translate([trans, 0, 0]) circle(r=S*radius);
        }
      }
    }
  }
}

// beveledhole cuts a hole through x-y plane in a child shape. The top and
// bottom surfaces are beveled with a radius depth/2. The hole will be scaled
// to width, height, depth dimensions. 
//
// Example usage:
//   beveledhole(5, 5, 5) cube(size=[20, 20, 20], center=true);
//
module beveledhole(width, height, depth) {
  // the area that will be subtracted has a slightly larger w & h.
  // but the opening will be limited to width & height.
  w = width;
  // w = width + depth;  // use this width if adding bevel to left & right walls.
  h = height + depth;
  r = depth / 2;

  difference() {
    children();

    // create "negative" form of beveled hole to subtrace from chidren above.
    difference(){
      // start with cube, and subtrace columns on each side.
      cube(size=[w,h,depth], center=true);

      // left & right walls.
      //rotate([90,0,0]) translate([ w/2, 0, 0]) cylinder(h=h, r=r, center=true);
      //rotate([90,0,0]) translate([-w/2, 0, 0]) cylinder(h=h, r=r, center=true);

      // top & bottom walls.
      rotate([0,90,0]) translate([0, -h/2, 0]) cylinder(h=w, r=r, center=true);
      rotate([0,90,0]) translate([0,  h/2, 0]) cylinder(h=w, r=r, center=true);
    }
  }
}

// squaredonuthole cuts a square "donut" hole through x-y plane of a child
// shape.  donut_radius is the radius of the donut that will be created. The
// intersection of this donut with the child shape is removed. A smaller radius
// creates a more pronounced curve. The hole is scaled to width, height, depth
// dimensions.
// 
// Example usage:
//     squaredonuthole(5, 5, 6, 7) cube(size=[20, 20, 6], center=true);
//
module squaredonuthole(width, height, depth, donut_radius) {
  radius = depth/2; 

  difference() {
    children();

    intersection() {
      scale([width/radius, height/radius, 1]) {
        translate([0, donut_radius, 0]) rotate([0, 90, 0]) {
          rotate_extrude(convexity = 10) {
            // rotate_extrude must start as an offset from x axis.
            translate([donut_radius, 0, 0]) square(radius, center=true);
          }
        }
      }
      scale([1, height/radius, 1])
        cube(size=[width, height, depth], center=true);
    }
  }
}


// helper functions for calculating the height of a donut arch segment.
function h(depth, tradius) = tradius - depth/2;
function b(depth, h) = sqrt( abs(pow(h, 2) - pow(depth/2, 2)) );
function archeight(depth, radius) = depth + h(depth, radius) - b(depth, h(depth, radius));

// donuthole cuts a round "donut" hole through x-y plane of a child shape.
// donut_radius is the radius of the donut that will be created. The
// intersection of this donut with the child shape is removed. A smaller radius
// creates a more pronounced curve. The hole is scaled to width, height, depth
// dimensions.
// 
// Example usage:
//     donuthole(5, 5, 6, 7) cube(size=[20, 20, 6], center=true);
//
module donuthole(width, height, depth, donut_radius) {
  radius = depth/2; 

  echo("cube:", [depth, archeight(depth, donut_radius), depth]);
  difference() {
    children();
    scale([width/depth, height/depth, 1]) {
      intersection() {
        translate([0, (radius)/2, 0])
          cube(size=[depth, donut_radius+radius, depth], center=true);

        translate([0, donut_radius, 0]) rotate([0, 90, 0]) {
          rotate_extrude(convexity = 10) {
            // rotate_extrude must start as an offset from x axis.
            translate([donut_radius, 0, 0]) circle(r=radius);
          }
        }
      }
    }
  }
}


// all circles are renedered using fn number of segments.
// higher value for more detail, but slower rendering.
// lower value for less detail and faster rendering.
// (I don't know if this affects the STL export or not.)
$fn = 30;

samplesize = [20,20,6];

translate([-20,0,0])
  roundhole(5, 5, 6, 0.01) cube(size=samplesize, center=true);

translate([0,0,0])
  beveledhole(5, 5, 6) cube(size=samplesize, center=true);

translate([20,0,0])
  squaredonuthole(5, 5, 6, 7) cube(size=samplesize, center=true);

translate([40,0,0])
  donuthole(5, 5, 6, 7) cube(size=samplesize, center=true);

