/* Adapter from 2-4 bowden tubes to input of Printrbot Gear Head Extruder. */

/* [Global] */

// Which part.
part = "block"; // [block]

// How many inputs
ntubes = 4; // [2,3,4]

/* [Hidden] */

// PFTE bowden tube
function tube_diam() = 4;
function core_diam() = 2;
function tube_extra_diam() = 0.5; // clearance for tube
function core_extra_diam() = 0.5; // clearance for filament
// plastic mount from filastruder
function mount_diam() = 12;
function mount_deep() = 7;
// interface to gear head extruder
function handle_diam() = 7.5; // for 8mm drill
function handle_deep() = 7;

// amount to enlarge diameter of holes to account for filament spread
function inner_clearance() = 0.5;
draft=false;
$fn = draft ? 12 : 48;

if (part=="block") {
  block("all");
} else if (part=="straight_bowden") {
  straight_bowden();
} else if (part=="straight_cluster") {
  straight_cluster();
} else if (part=="curved_bowden") {
  curved_bowden();
} else if (part=="curved_cluster") {
  curved_cluster();
}

module block(part="all", ntubes=ntubes) {
  // less sharp, fits on gearhead extruder v0.02 better
  curve_radius = 50;
  length = 36;
  block_cutoff = 19;
  cone_height = 37.8;
  cone_diam = 16;
  extra_len = 10;
  /*
  // most compact:
  block_cutoff = 10.5;
  curve_radius = 20;
  cone_height = 27.4;
  cone_diam = 20;
  length = 26;
  extra_len = 10;
  */

  if (part=="all") {
    difference() {
      block(part="outside");
      block(part="hole");
      difference() {
        cube([cone_diam,cone_diam,2*handle_deep()], center=true);
        cylinder(d=handle_diam(), h=3*handle_deep(), center=true);
      }
    }
  } else if (part=="outside") {
    wall=2;
    union() {
      // aids printability by giving flat face on bottom
      translate([0,0,cone_height]) scale([1,1,-1])
        cylinder(d1=cone_diam,
                 d2=handle_diam()-0.5,
                 //was: d2=core_diam() + core_extra_diam() + 2*wall,
                 h=cone_height);
      curved_cluster(part="core", ntubes=ntubes,
                curve_radius=curve_radius, length=length,
                extra_diam=mount_diam() - core_diam() + 2*wall,
                cutoff_length=length - mount_deep() - wall);
      curved_cluster(part="tube", ntubes=ntubes,
                curve_radius=curve_radius, length=length,
                extra_diam=2*wall, cutoff_length = block_cutoff - wall);
    }
  } else if (part=="hole") {
    curved_cluster(part="core", ntubes=ntubes,
                   curve_radius=curve_radius, length=length,
                   extra_len=1,
                   extra_diam=core_extra_diam() + inner_clearance());
    curved_cluster(part="hole", ntubes=ntubes,
                   curve_radius=curve_radius, length=length,
                   extra_len=extra_len, extra_diam=inner_clearance());
    curved_cluster(part="tube", ntubes=ntubes,
                   curve_radius=curve_radius, length=length,
                   cutoff_length=block_cutoff,
                   extra_diam=tube_extra_diam() + inner_clearance());
  }
}

module straight_cluster(part="all", ntubes=ntubes, angle=25, length=28) {
  rotate([0,0,ntubes==4 ? 45: 0])
  for(i=[1:(draft?1:ntubes)]) rotate([0,0,i*(360/ntubes)]) {
    rotate([angle, 0, 0]) straight_bowden(part=part, length=length);
  }
}

module curved_cluster(part="all", ntubes=ntubes, curve_radius=50, length=36, cutoff_length=0, extra_len=0, extra_diam=0) {
  rotate([0,0,ntubes==4 ? 45: 0])
  for(i=[1:(draft?1:ntubes)]) rotate([0,0,i*(360/ntubes)]) {
    curved_bowden(part=part, length=length, curve_radius=curve_radius,
                  cutoff_length=cutoff_length,
                  extra_len=extra_len, extra_diam=extra_diam);
  }
}

module curved_bowden(part="all", length=28, curve_radius=20, cutoff_length=0, extra_len=0, extra_diam=0) {
  epsilon = .1;
  // compute curve_angle from length (2*pi*r / 360)
  curve_angle = (length - mount_deep()) * 360 / (2*PI*curve_radius);
  cutoff_angle = (cutoff_length > 0 ? cutoff_length : -extra_len) * 360 / (2*PI*curve_radius);

  if (part=="all") {
    curved_bowden(part="cap", length=length, curve_radius=curve_radius);
    difference() {
      curved_bowden(part="tube", length=length, curve_radius=curve_radius);
      curved_bowden(part="core", length=length, curve_radius=curve_radius, extra_len=epsilon);
    }
  } else if (part=="tube" || part=="core") {
    diam = ((part=="tube") ? tube_diam() : core_diam()) + extra_diam;
    translate([-curve_radius,0,0]) rotate([90,0,0]) intersection() {
      rotate_extrude(convexity=10)
        translate([curve_radius, 0, 0])
          circle(d=diam);
      linear_extrude(height = 2*diam, center=true, convexity=10)
        polygon(points=[
          [0, 0],
          [curve_radius+diam, tan(cutoff_angle)*(curve_radius+diam)],
          [curve_radius+diam, tan(curve_angle)*(curve_radius+diam)]
        ]);
    }
    translate([-curve_radius,0,0]) rotate([0,-curve_angle,0])
      translate([curve_radius,0,-epsilon])
        cylinder(d=diam, h=mount_deep() + epsilon + extra_len);
  } else if (part=="hole") {
    translate([-curve_radius,0,0]) rotate([0,-curve_angle,0])
      translate([curve_radius,0,0])
        cylinder(d=mount_diam() + extra_diam, h=mount_deep() + extra_len);
  } else if (part=="cap") {
    difference() {
      curved_bowden(part="hole", length=length, curve_radius=curve_radius);
      curved_bowden(part="tube", length=length, curve_radius=curve_radius,
                    extra_len=epsilon, extra_diam=inner_clearance());
    }
  }
}

module straight_bowden(part="all", length=30, cutoff_length=0, extra_len=0, extra_diam=0) {
  cutoff = (cutoff_length > 0 ? cutoff_length : -extra_len);
  epsilon = .1;

  if (part=="all") {
    straight_bowden(part="cap", length=length);
    difference() {
      straight_bowden(part="tube", length=length);
      straight_bowden(part="core", length=length, extra_len=epsilon);
    }
  } else if (part=="tube" || part=="core") {
   diam = ((part=="tube") ? tube_diam() : core_diam()) + extra_diam;
   translate([0,0,cutoff])
   cylinder(d=diam, h=length + extra_len - cutoff);
  } else if (part=="hole") {
    translate([0,0,length - mount_deep()])
      cylinder(d=mount_diam() + extra_diam, h=mount_deep() + extra_len);
  } else if (part=="cap") {
    difference() {
      straight_bowden(part="hole", length=length);
      straight_bowden(part="tube", length=length,
                      extra_len=epsilon, extra_diam=inner_clearance());
    }
  }
}
