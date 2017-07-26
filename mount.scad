/*
 * Extruder mount onto SPANNERHANDS Filament Spools
 * https://www.thingiverse.com/thing:2119644
 */

/* [Global] */

size = "1kg"; // [750g, 1kg]
with_nema_plate = true; // [false,true]

/* [Hidden] */

mount_width = (size=="1kg") ? 100 : 66;
// 3 pieces, which we call A, B, and C.
a_thick = 3;
b_thick = 3;
c_thick = with_nema_plate ? 3 : 0;
// offset extruder from center in order to clear screws
stepper_offset = 3;
$fn=48;

function inch() = 25.4;
// hole diameter for an M3 screw
function m3_clear() = 3.4;
// amount to enlarge diameter of holes to account for filament spread
function inner_clearance() = 0.5;

module mount() {
  hotend_height = 21; // hotend spacing above top of A
  hotend_diam = 16 + 0.5/*clearance*/;
  hotend_setback_width = 12;
  hotend_to_wall_width = 22 - 11;
  stepper_shaft_diam = 5 + 2/*clearance*/;
  stepper_ring_diam = 22;
  stepper_ring_depth = 2;
  nema17_mount = 31;
  extruder_mount_height = 30; // spacing between extruder mounting holes
  extruder_mount_width = 16; // spacing between extruder mounting holes

  a_width = mount_width;
  a_depth = 48 + b_thick;
  a_height = a_thick;

  b_width = a_width/2 + stepper_offset + hotend_setback_width;
  b_depth = b_thick;
  b_height = a_thick + hotend_height + 28;

  c_width = c_thick;
  c_depth = a_depth;
  c_height = b_height;

  // part a
  if (a_thick > 0) difference() {
    translate([-a_width/2, -(a_depth - 24), 0])
      cube([a_width, a_depth, a_height]);
    for (i=[-1,1]) for (j=[-1,1]) scale([i,j,1])
      translate([16,16,0])
        m3_hole();
  }
  // part b
  if (b_thick > 0) difference() {
    translate([-a_width/2, -(a_depth - 24), 0])
      cube([b_width, b_depth, b_height]);
    translate([stepper_offset, -(a_depth - 24), a_thick + hotend_height]) {
      rotate([90,0,0])
        cylinder(d=hotend_diam + inner_clearance(), h=3*b_thick, center=true);
      translate([0,0,-8]) {
        for (i=[-1,1]) scale([i,1,1]) {
          translate([-extruder_mount_width/2,0,extruder_mount_height])
            rotate([90,0,0]) m3_hole();
        }
        translate([-extruder_mount_width/2,0,0])
          rotate([90,0,0]) m3_hole();
      }
    }
  }
  // part c
  if (c_thick > 0) difference() {
    translate([stepper_offset - hotend_to_wall_width - c_thick,
               -(a_depth - 24), 0])
      cube([c_width, c_depth, c_height]);
    translate([stepper_offset - hotend_to_wall_width - c_thick,
               0,
               a_thick + hotend_height - 8 + extruder_mount_height/2]) {
      rotate([0,90,0]) {
        cylinder(d=stepper_shaft_diam + inner_clearance(), h=3*c_thick, center=true);
        cylinder(d=stepper_ring_diam + inner_clearance(), h=2*stepper_ring_depth, center=true);
      }
      for (i=[-1,1]) for (j=[-1,1]) scale([1,i,j])
        translate([0,nema17_mount/2,nema17_mount/2])
          rotate([0,90,0]) m3_hole();
    }
  }
}

module m3_hole(h=10, center=true) {
  cylinder(d=m3_clear() + inner_clearance(), h=h, center=center);
}

mount();
