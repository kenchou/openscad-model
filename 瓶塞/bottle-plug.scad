$fa = 1;
$fs = 0.4;
shank_diameter = 15.5;
shank_diameter_increase = 1;
shank_length = 20;
shank_chamfer = 3;
knob_length = 15;
knob_diameter = 26;
upper_knob_chamfer = 3;
lower_knob_chamfer = 1;

// upper knob chamfer
cylinder(h=upper_knob_chamfer, r1 = knob_diameter / 2 - upper_knob_chamfer, r2 = knob_diameter / 2); 

// knob and shank body
translate([0, 0, upper_knob_chamfer]) {
    cylinder(h = knob_length, r = knob_diameter / 2); // knob
    cylinder(
        h = knob_length + shank_length, 
        r1 = shank_diameter / 2, 
        r2 = shank_diameter / 2 + shank_diameter_increase / 2);
}

// lower knob chamfer
translate([0, 0, upper_knob_chamfer + knob_length]) 
    cylinder(
        h=lower_knob_chamfer, 
        r1=knob_diameter / 2, 
        r2=knob_diameter / 2 - lower_knob_chamfer);

// shank chamfer
translate([0, 0, upper_knob_chamfer + knob_length + shank_length]) 
    cylinder(
        h=shank_chamfer, 
        r1=shank_diameter / 2 + shank_diameter_increase / 2, 
        r2=shank_diameter / 2 + shank_diameter_increase / 2 - shank_chamfer); 
