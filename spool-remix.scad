/**
 * Remix of "v5_Small_Volume_1kg_LID_2.stl" from
 * https://www.thingiverse.com/thing:2119644
 * to add PFTE coupling mount.
 */

/* [Global] */

part = "hanger"; // [lid2,hanger]

/* [Hidden] */

use <./mount.scad>
$fn=48;

if (part=="lid1" || part=="lid2") {
  remixed_lid(part=part);
} else if (part=="hanger") {
  remixed_hanger();
}

module lid1() {
  translate([-120,0,-97])
  import("remix/v5_Small_Volume_1kg_LID_1.stl", convexity=10);
  // mounting hole is at [0,98,0] in this version
}

module lid2() {
  translate([-120,0,-4.75])
  import("remix/v5_Small_Volume_1kg_LID_2.stl", convexity=10);
  // mounting hole is at [0,98,0] in this version
}

module remixed_lid(part="lid2") {
  is_lid1 = (part=="lid1");
  spannerhands_spacing = 33;

  difference() {
    if (is_lid1) { lid1(); } else { lid2(); }
    translate(is_lid1 ? [0,98,0] : [0,107,0]) {
      cylinder(d=30, h=10, center=true);
      for (i=[1,-1]) for (j=[1,-1]) scale([i,j,1]) {
        translate([spannerhands_spacing/2, spannerhands_spacing/2,0])
          m3_hole();
      }
    }
  }
}

module hanger() {
  translate([0,0,15]) rotate([0,90,0])
    import("remix/WALL_MOUNT_v2_0.stl", convexity=10);
}

module remixed_hanger() {
  // notch for stepper wire to pass through
  difference() {
    hanger();
    translate([-6,0,26])
      cube([12,60,4.5]);
  }
}
