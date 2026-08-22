include <BOSL2/std.scad>

module base(){
    difference() {
        cyl(h=base_h, r=base_r, chamfer2=1, anchor=BOTTOM) position(CENTER+BOTTOM) 
            translate([20, 0, 0]) cube([6, 16, base_h], anchor=BOTTOM);
        translate([0,0,-3]) cylinder(h=10, r=3);
    };
//    translate([20, 0, 0]) cube([16, 16, base_h], anchor=BOTTOM);
}

module rib() {
    union() {
    difference() {
        right_half() 
            tube(h=interface_h, or=20, ir=base_r-1, anchor=BOTTOM) 
            position(CENTER+BOTTOM) 
            translate([20, 0, 0])
                rect_tube(h=interface_h, size=[6+2, 16], wall=1, anchor=BOTTOM);
        cyl(h=interface_h, r=base_r-1, anchor=BOTTOM) position(CENTER+BOTTOM) translate([20, 0, 0]) cube([6,14,interface_h+10], anchor=BOTTOM);
        translate([-5,0,0]) ycyl(h=50, r=30, anchor=BOTTOM);
    };
    translate([23,0,4]) fillet(l=16, r=5.35, ang=90, spin=180, orient=BACK);
    }
}

base();
rib();
//rect_tube(h=interface_h, size=[16, 16], wall=1, anchor=BOTTOM);


$fn=64;
base_h=4;
base_r=20;
interface_h=30;
