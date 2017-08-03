/**
 * Remix of "Printrbot_Gear_Head_v0.02.1.stl" from
 * https://www.youmagine.com/designs/printrbot-gear-head-extruder
 * to add hotend capture ridge and mount for N-way bowden coupler.
 */

/* [Global] */

part = "all"; // [base, clamp, gearbox]

/* [Hidden] */

use <./mount.scad>
use <./bowden.scad>
$fn=48;

function bowden_coupler_off() = [7,0,11.3];
function bowden_coupler_len() = 7;

if (part=="walter") {
  walter_gearhead_remix();
  if (false) { // visualization for checking bearing size only
    translate([5,0,7.1])
      walter_bearing();
    translate([5,0,-4.5])
      walter_bearing();
  }
} else {
  gearhead_remix(part=part);
  if (part=="all") {
    translate(bowden_coupler_off()) rotate([0,90,0])
      block(part="all", ntubes=3);
  }
}

module gearhead() {
  // From: https://www.youmagine.com/designs/printrbot-gear-head-extruder
  translate([0,4.76,-2.56])
  import("remix/Printrbot_Gear_Head_v0.02.1.stl", convexity=10);
}

module walter_gearhead() {
  // From: https://www.thingiverse.com/thing:1052966
  // Move filament path to y axis and gear centers to x axis
  translate([-26.645,-21.325,-9.03])
  import("remix/Gearhead_v6-1.STL", convexity=10);
}

// ** Remix of Printrbot Gear Head extruder design **

module gearhead_bounds(part="base") {
  if (part=="base") {
    cube([50,55,30.3], center=true);
  } else if (part=="clamp") {
    translate([-18,52,0])
      cube([16,49,26.8], center=true);
  } else if (part=="gearbox") {
    translate([0,52,0])
      cube([20,49,19.2], center=true);
  } else if (part=="clamp-split") {
    translate([-20.73,0,11.3])
    cube([20,65,4], center=true);
  } else if (part=="gear-split") {
    translate([9.3,0,15.1])
    cube([40,65,0.5], center=true);
  }
}

module gearhead_part(part, just_bounds=false) {
  if (just_bounds) {
    gearhead_bounds(part=part);
  } else {
    intersection() {
      gearhead();
      gearhead_bounds(part=part);
    }
  }
}

module gearhead_assembled(part, just_bounds=false) {
  if (part=="all") {
    gearhead_assembled("base", just_bounds);
    gearhead_assembled("clamp", just_bounds);
    gearhead_assembled("gearbox", just_bounds);
  } else if (part=="base") {
    gearhead_part(part, just_bounds);
  } else if (part=="clamp" || part=="gearbox") {
    translate([0,55.925,24.64])
      rotate([180,0,0])
      gearhead_part(part, just_bounds);
  }
}

module gearhead_remix(part="all") {
  extruder_stop_off = [-10.71,0,bowden_coupler_off().z];
  intersection() {
    union() {
      difference() {
        union() {
          gearhead_assembled(part);
          difference() {
            translate(bowden_coupler_off()) rotate([0,90,0])
              ring(outer=12, inner=7, height=bowden_coupler_len());
            gearhead_bounds("gear-split");
          }
        }
        // bowden coupler mount
        translate(bowden_coupler_off()) // original guide is d=2.3 here
          rotate([0,90,0])
            cylinder(d=8, h=bowden_coupler_len() + 1);
      }
      // add extruder stop
      epsilon = .05;
      if (part=="clamp") difference() {
        translate(extruder_stop_off) rotate([0,-90,0]) difference() {
          translate([0,0,3 + epsilon])
            cylinder(d=18, h=1.5+.75 - epsilon);
          cylinder(d=12, h=6);
          translate([0,0,3])
            cylinder(d1=16, d2=12, h=1.5);
        }
        gearhead_bounds("clamp-split");
      }
    }
    union() {
      gearhead_assembled(part, just_bounds=true);
      if (part=="all" || part=="gearbox") {
        translate([bowden_coupler_len(),0,0]) gearhead_assembled(part, just_bounds=true);
      }
    }
  }
}

// ** Remix of Printrbot Gear Head extruder design **

module walter_gearhead_remix() {
  walter_gearhead();
  // TO DO:
  // 1. Add mount for bowden merge piece.
  // 2. Add hotend mount, w/ set screw through groove to secure?
  // 3. Add printrbot-standard mounting holes on bottom; trim bottom
  // to correct height; fill in existing mounting holes
  // 4. Add ring around bearing printed in flexible filament so that
  // "tension adjustment" setscrew affects force not position?
}

module walter_bearing() {
  ring(outer=8, inner=5, height=2.5); // 5x8x2.5mm, like on original kit
}


// ** Utilities **

module ring(outer, inner, height, center=false) {
  epsilon=.1;
  translate([0,0,center?(-height/2):0]) difference() {
    cylinder(d=outer, h=height);
    translate([0,0,-epsilon])
      cylinder(d=inner, h=height + 2*epsilon);
  }
}
