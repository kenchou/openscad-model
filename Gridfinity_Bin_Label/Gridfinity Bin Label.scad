include <BOSL2/std.scad>;

/* [Dimensions] */
width = 37.7;
depth = 12;
baseplate_thickness = 1; 
text_thickness = 0.6;
/* [Label] */
label = "Text";
icon = "None"; // [None, Countersunk, Socket Head, Socket Head2, Phillips Head, Slotted Head, Torx Head, Lens Head, Hexagon Head, Grub Screw, Nut, Washer, Heat Set Insert, Magnet, Magnet-U, Ball Bearing, Spring, Resistor, Capacitor, LED, Motor, Connector, Heat Shrink Tube]
icon_spacing = 1;
font = "HarmonyOS Sans SC:style=Black"; //font
text_size = 5;
//reduces the width by 2mm, in order to add 1mm Pred Tabs on both sides
Pred_Tabs = false;
//for a cleaner look
Remove_Pred_Tab_Holes = false;
/* [Batch Export] */
//Create multiple Labels by seperating the Text with the Seperator-Character below
batch_export = false;
seperator = ",";
//How many Labels should be in one Column
columns = 3; 
/* [Color] */
base_color = "#ffffff"; //color
text_color = "#000000"; //color
frame_color = "#000000"; //color
icon_color = "#000000"; //color
color_magnet_icon = true;
/* [Hidden] */
frame_thickness = 1;
text_w = textmetrics(text=label, size=text_size, font=font);
icon_position = 0;

//////////////////////////////////////////////////////////////
//              SWITCH: SINGLE OR BATCH LABELS              //
//////////////////////////////////////////////////////////////
if(batch_export == false) {
    label(label_text=label, text_width=text_w);
} else {
    generate_multiple_labels();
}

//////////////////////////////////////////////////////////////
//            BATCH LABEL GENERATION (Multiple)             //
//          code partly by @3DLG from Makerworld            //
//               and by @jryan15 on reddit                  //
//////////////////////////////////////////////////////////////
module generate_multiple_labels() {
    text_array = str_split(label, seperator);

    horizontal_offset = width+3;
    vertical_offset = depth+3;
    
    for(i = [0 : len(text_array) - 1]) {
        text_w = textmetrics(text=text_array[i], size=text_size, font=font);
        
        row = floor(i / columns);
        col = i % columns;
        
        translate([horizontal_offset * col, row * -vertical_offset, 0])
            label(label_text=text_array[i], text_width=text_w);
    }
}

module label(label_text="", text_width=0) {
    baseplate_width = Pred_Tabs ? width-2 : width;
    pred_tab_offset = Pred_Tabs ? 1 : 0;

    difference() {
        union() {
            //Baseplate
            translate([pred_tab_offset, 0, 0])
                color(base_color) rounded_plate(size = [baseplate_width, depth], radius = 2, height = baseplate_thickness);
            //Frame
            translate([pred_tab_offset, 0, baseplate_thickness])
                color(frame_color) rounded_frame([baseplate_width, depth], radius=2, frame_thickness, text_thickness);
            //Pred Tabs
            if(Pred_Tabs == true) {
                pred_tabs();
                
            }
        }
        if(Pred_Tabs == true && Remove_Pred_Tab_Holes == false) {
            translate([1.5, depth/2, 0])
                cylinder(h=baseplate_thickness+text_thickness, d=1.5, $fn=50);
            translate([width-1.5, depth/2, 0])
                cylinder(h=baseplate_thickness+text_thickness, d=1.5, $fn=50);
        }
    }

    //Icons & Text
    translate([width/2, depth/2, baseplate_thickness]) {
        //Icons
        if(icon == "Socket Head") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         1);
            socket_head(i_position=icon_position);
        }
        if(icon == "Phillips Head") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            phillips_head(i_position=icon_position);
        }
        if(icon == "Slotted Head") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            slotted_head(i_position=icon_position);
        }
        if(icon == "Socket Head2") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            socket_head2(i_position=icon_position);
        }
        if(icon == "Torx Head") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            torx_head(i_position=icon_position);
        }
        if(icon == "Countersunk") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         2.1);
            countersunk(i_position=icon_position);
        }
        if(icon == "Grub Screw") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         2.1);
            grub_screw(i_position=icon_position);
        }
        if(icon == "Nut") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            nut(i_position=icon_position);
        }
        if(icon == "Hexagon Head") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            hexagon_head(i_position=icon_position);
        }
        if(icon == "Washer") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            washer(i_position=icon_position);
        }
        if(icon == "Lens Head") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         1);
            lens_head(i_position=icon_position);
        }
        if(icon == "Heat Set Insert") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            heat_set_insert(i_position=icon_position);
        }
        if(icon == "Magnet") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            magnet(i_position=icon_position);
        }
        if(icon == "Magnet-U") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         0.5);
            magnet_u(i_position=icon_position);
        }
        if(icon == "Ball Bearing") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         0.5);
            ball_bearing(i_position=icon_position);
        }
        if(icon == "Spring") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         1);
            spring(i_position=icon_position);
        }
        if(icon == "Resistor") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         1);
            resistor(i_position=icon_position);
        }
        if(icon == "Capacitor") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         1);
            capacitor(i_position=icon_position);
        }
        if(icon == "LED") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         1);
            led(i_position=icon_position);
        }
        if(icon == "Motor") {
            icon_position = (text_width["size"][0]/2 + icon_spacing +         1);
            motor(i_position=icon_position);
        }
        if(icon == "Connector") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         1);
            connector(i_position=icon_position);
        }
        if(icon == "Heat Shrink Tube") {
            icon_position = (text_width["size"][0]/2 + icon_spacing -         1);
            heat_shrink_tube(i_position=icon_position);
        }
        
        //Text without Icon offset
        if(icon == "None") {
            translate([0, 0, 0]) {
                color(text_color) linear_extrude(text_thickness) {
                    text(label_text, size=text_size, halign="center", valign="center", font=font);
                }
            }
        } else { //Text with Icon offset
            translate([2+icon_spacing, 0, 0]) {
                color(text_color) linear_extrude(text_thickness) {
                    text(label_text, size=text_size, halign="center", valign="center", font=font);
                }
            }
        }

    }
}

//Rounded baseplate
module rounded_plate(size, radius, height) {
    assert(radius <= min(size)/2, "Radius too big!");

        linear_extrude(height)
            hull() {
                translate([radius, radius])
                    circle(r=radius, $fn=32);
                translate([size[0] - radius, radius])
                    circle(r=radius, $fn=32);
                translate([size[0] - radius, size[1] - radius])
                    circle(r=radius, $fn=32);
                translate([radius, size[1] - radius])
                    circle(r=radius, $fn=32);
            }
}

//Rounded Frame
module rounded_frame(size, radius, thickness, height) {
        linear_extrude(height)
            difference() {
                offset_shell([size[0], size[1]], radius);
                translate([thickness, thickness])
                    offset_shell([size[0] - 2*thickness, size[1] - 2*thickness], radius - thickness);
            }
}

//Offset Shell
module offset_shell(size, radius) {
    hull() {
        translate([radius, radius])
            circle(r=radius, $fn=32);
        translate([size[0] - radius, radius])
            circle(r=radius, $fn=32);
        translate([size[0] - radius, size[1] - radius])
            circle(r=radius, $fn=32);
        translate([radius, size[1] - radius])
            circle(r=radius, $fn=32);
    }
}

module pred_tabs() {
    //Left Tabs
    translate([0, depth/2-5.7/2, 0]) {
        color(base_color) cube([1, 5.7, baseplate_thickness]);
        translate([0, 0, baseplate_thickness]) {
            color(frame_color) cube([1, 5.7, text_thickness]);
        }
    }
    if(Remove_Pred_Tab_Holes == false) {
        translate([1.5, depth/2, baseplate_thickness])
            color(frame_color) cylinder(h=text_thickness, d=2.5, $fn=50);
    }

    //Right Tabs
    translate([width-1, depth/2-5.7/2, 0]) {
        color(base_color) cube([1, 5.7, baseplate_thickness]);
        translate([0, 0, baseplate_thickness]) {
            color(frame_color) cube([1, 5.7, text_thickness]);
        }
    }
    if(Remove_Pred_Tab_Holes == false) {
        translate([width-1.5, depth/2, baseplate_thickness])
            color(frame_color) cylinder(h=text_thickness, d=2.5, $fn=50);
    }
        
}

//////////////////////////////////////////////////////////////
//                          SHAPES                          //
//////////////////////////////////////////////////////////////

// Torx star shape for top view | Code by @3DLG from Makerworld
module Torx_star(points, point_len, height=2, rnd=0.1) {
    fn=25;
    point_deg = 360 / points;
    point_deg_adjusted = point_deg + (-point_deg / 2);

    for (i = [0 : points - 1]) {
        rotate([0, 0, i * point_deg])
        translate([0, -point_len, 0])
            point(point_deg_adjusted, point_len, rnd, height, fn);
    }  
    
    module point(deg, leng, rnd, height, fn=25) {
        hull() {
            cylinder(height, d=rnd, $fn=fn); // Base cylinder at the center
            rotate([0, 0, -deg / 2])
                translate([0, leng, 0]) cylinder(height, d=rnd); // Left edge
            rotate([0, 0, deg / 2])
                translate([0, leng, 0]) cylinder(height, d=rnd); // Right edge
        }
    }
}

//////////////////////////////////////////////////////////////
//                          ICONS                           //
//////////////////////////////////////////////////////////////
module countersunk(i_position=0) {
    color(icon_color)
        translate([-i_position, 2.5, 0]) {
            rotate([0, 0, -45]) {
                linear_extrude(text_thickness) {
                     polygon(points=[[0,0], [3,0], [3,3]]);
                }
            }   
        }
        translate([-i_position+1.1, -2.4, 0]) {
            color(icon_color) cube([2, 4, text_thickness]);
        }
}

module grub_screw(i_position=0) {
    color(icon_color)
        translate([-i_position+3.1, 1.6, 0]) {
            rotate([0, 0, 135]) {
                linear_extrude(text_thickness) {
                     polygon(points=[[0,0], [1.4,0], [1.4,1.4]]);
                }
            }   
        }
        translate([-i_position+1.1, -2.7, 0]) {
            color(icon_color) cube([2, 4.3, text_thickness]);
        }
        
}

module phillips_head(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness)
                    circle(r=3, $fn=50);
                translate([-2, -0.5, 0])
                    cube([4, 1, text_thickness+1]);
                translate([-0.5, -2, 0])
                    cube([1,4,text_thickness+1]);
            }
    }
}

module torx_head(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness)
                    circle(r=3, $fn=50);
                Torx_star(6, 2, height=text_thickness+1, rnd=0.1);
                cylinder(h=text_thickness+1, d=1);
            }
    }
}

module socket_head(i_position=0) {
    translate([-1-i_position, 0.5, 0]) {
        color(icon_color) cube([4, 2, text_thickness]); //Screw Head
    }
    translate([-i_position, -2.4, 0]) {
        color(icon_color) cube([2, 4, text_thickness]); //Screw Thread
    }
}

module socket_head2(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness)
                    circle(r=3.2, $fn=50);
                linear_extrude(text_thickness+1)
                    circle(r=2.2, $fn=6);
                
            }
    }
}

module hexagon_head(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            linear_extrude(text_thickness)
                circle(r=3, $fn=6);
    }
}

module lens_head(i_position=0) {

    translate([-i_position+1, 0.5, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness) 
                     circle(d=4, $fn=50);
                translate([-2, -2, 0])
                    cube([4, 2, text_thickness+1]);
            }
    }
    translate([-i_position, -2.4, 0]) {
        color(icon_color) cube([2, 4, text_thickness]); //Screw Thread
    }
}

module nut(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness)
                    circle(r=3, $fn=6);
                    
                translate([0, 0, -text_thickness*2])
                    cylinder(h=text_thickness*4, r=1, $fn=50);
            }
    }
}

module washer(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness)
                    circle(r=3, $fn=50);
                    
                translate([0, 0, -text_thickness*2])
                    cylinder(h=text_thickness*4, r=1.5, $fn=50);
            }
    }
}

module heat_set_insert(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                linear_extrude(text_thickness)
                    union() {
                        circle(r=3, $fn=5);
                        rotate([0, 0, 36]) circle(r=3, $fn=5);
                    }
                translate([0, 0, -text_thickness*2])
                    cylinder(h=text_thickness*4, r=1.2, $fn=50);
            }
    }
}

module slotted_head(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color)
            difference() {
                cylinder(h=text_thickness, r=3, $fn=50);
                translate([-3, -0.5, 0])
                cube([6, 1, text_thickness*2]);
                
            }
    }
}

module magnet(i_position=0) {
    magnet_positive_color = color_magnet_icon ? "#F4493C" : icon_color;
    magnet_negative_color = color_magnet_icon ? "#207AD3" : icon_color;
    translate([-1-i_position, 0, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([6, 2, text_thickness]);
        color(magnet_positive_color)
            translate([0, 1, 0])
                linear_extrude(text_thickness)
                    text(text="+", size=4, font="HarmonyOS Sans SC:style=Black", halign="center");
        color(magnet_negative_color)
            translate([0, -4.5, 0])
                linear_extrude(text_thickness)
                    text(text="-", size=4, font="HarmonyOS Sans SC:style=Black", halign="center");
    }
}

module magnet_u(i_position=0) {
    magnet_positive_color = color_magnet_icon ? "#F4493C" : icon_color;
    magnet_negative_color = color_magnet_icon ? "#207AD3" : icon_color;
    translate([-1-i_position, 0, 0]) {
        color(icon_color) {
            
                difference() {
                    union() {
                        translate([-3, -1, 0])
                            cube([6, 3, text_thickness]);
                            translate([0, -1, 0])
                                cylinder(h=text_thickness, d=6, $fn=50);
                    }
                    translate([-3, 1, 0])
                        cube([6, 1, text_thickness+1]);
                    translate([-1, -1, 0])
                        cube([2, 4, text_thickness+1]);
                        translate([0, -1, 0])
                            cylinder(h=text_thickness+1, d=2, $fn=50);
                }
        }
        color(magnet_positive_color)
            translate([-2, 1, 0])
                linear_extrude(text_thickness)
                    text(text="+", size=4, font="HarmonyOS Sans SC:style=Black", halign="center");
        color(magnet_negative_color)
            translate([+2, 1.34, 0])
                linear_extrude(text_thickness)
                    text(text="-", size=4, font="HarmonyOS Sans SC:style=Black", halign="center");
    }
}

module ball_bearing(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color) {
            difference() {
                cylinder(h=text_thickness, d=8, $fn=50);
                cylinder(h=text_thickness, d=7, $fn=50);
            }
            difference() {
                cylinder(h=text_thickness, d=4, $fn=50);
                cylinder(h=text_thickness, d=3, $fn=50);
            }
            for(i = [0:7]) {
                rotate([0, 0, (360/8)*i])
                    translate([0, 2.75, 0])
                        cylinder(h=text_thickness, d=1.5, $fn=50);
            }
        }
    }
}

module spring(i_position=0) {
    translate([-2-i_position, 0, 0]) {
        color(icon_color) {
            translate([-0, +2.5, 0])
                rotate([0, 0, -15])
                    cube([5.29, 1, text_thickness]);
            translate([-0, -0.24, 0])
                rotate([0, 0, 15])
                    cube([5.29, 1, text_thickness]);
            translate([-0, -0.24, 0])
                rotate([0, 0, -15])
                    cube([5.29, 1, text_thickness]);
            translate([-0, -2.98, 0])
                rotate([0, 0, 15])
                    cube([5.29, 1, text_thickness]);
            translate([0, 2.5, 0])
                cube([5.4, 1, text_thickness]);
            translate([0, -3, 0])
                cube([5.4, 1, text_thickness]);
        }
    }
}

module resistor(i_position=0) {

    translate([-1-i_position, 0, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([5, 2, text_thickness]);
    }
    
    translate([-3-i_position, 0.5, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([6, 1, text_thickness]);
    }
    
    translate([-i_position, 0.5, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([6, 1, text_thickness]);
    }
    
    translate([-1-i_position, -0.5, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([1.5, 3, text_thickness]);
    }
    
    translate([-i_position+2.5, -0.5, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([1.5, 3, text_thickness]);
    }
}

module capacitor(i_position=0) {

    translate([-1-i_position, 0, 0]) {
        color(icon_color) 
            difference() {
                translate([-3, -1, 0])
                    cube([4, 5, text_thickness]);
                
                translate([0.5, 0, 0])
                    cube([1, 1, text_thickness+1]);
                
                translate([-3.5, 0, 0])
                    cube([1, 1, text_thickness+1]);
            }
    }
    
    translate([-0.5-i_position, -2, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([1, 2, text_thickness]);
    }
    
    translate([-i_position+1.5, -3, 0]) {
        color(icon_color) 
            translate([-3, -1, 0])
                cube([1, 3, text_thickness]);
    }
}

module led(i_position=0) {
    translate([-1-i_position, 0.5, 0]) {
        color(icon_color) {
            
            union() {
                translate([-3, -1.5, 0])
                    cube([4, 3, text_thickness]);
                    translate([-3.5, -1.5, 0])
                        cube([5, 1, text_thickness]);
                    translate([-2.5, -4, 0])
                        cube([0.8, 2.5, text_thickness]);
                    translate([-0.2, -4.5, 0])
                        cube([0.8, 3, text_thickness]);
                    translate([-1, 1.5, 0])
                        cylinder(h=text_thickness, d=4, $fn=50);
            }
        }
    }
}

module motor(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color) {
            
            union() {
                translate([-3, -2, 0])
                    cube([5, 4, text_thickness]);
                    translate([2, -0.5, 0])
                        cube([2, 1, text_thickness]);
                    translate([-4, 0.7, 0])
                        cube([2, 0.8, text_thickness]);
                    translate([-4, -1.5, 0])
                        cube([2, 0.8, text_thickness]);
            }
        }
    }
}

module connector(i_position=0) {
    translate([-1-i_position, 0.5, 0]) {
        color(icon_color) {
            
            union() {
                translate([-3, -1, 0])
                    cube([4, 2, text_thickness]);
                    translate([-1.5, -4, 0])
                        cube([1, 2, text_thickness]);
                    translate([-2.5, 1, 0])
                        cube([0.8, 2, text_thickness]);
                    translate([-0.2, 1, 0])
                        cube([0.8, 2, text_thickness]);
                    translate([-1, -1, 0])
                        cylinder(h=text_thickness, d=4, $fn=50);
            }
        }
    }
}

module heat_shrink_tube(i_position=0) {
    translate([-1-i_position, -0.8, 0]) {
        color(icon_color) {
            rotate([0, 0, -15])
            {
            
                difference() {
                    union() {
                        
                        {
                            translate([-7, -2, 0])
                                cube([7, 4, text_thickness]);
                            translate([0, 0, 0])
                                scale([0.75, 1, 1])
                                    cylinder(h=text_thickness, d=4, $fn=50);
                            translate([-7, 0, 0])
                                scale([0.75, 1, 1])
                                    cylinder(h=text_thickness, d=4, $fn=50);
                        }
                    }
                    translate([-0.25, 0, 0])
                            scale([0.75, 1, 1])
                                cylinder(h=text_thickness, d=3, $fn=50);
                    

                }
                

            }
        }
    }
}

//Old design
module heat_shrink_tube2(i_position=0) {
    translate([-1-i_position, 0, 0]) {
        color(icon_color) {
            
                difference() {
                    union() {
                        translate([-3, -3.5, 0])
                            cube([4, 7, text_thickness]);
                    }
                    translate([-5.5, 0, 0])
                        cylinder(h=text_thickness, d=6, $fn=50);
                    translate([3.5, 0, 0])
                        cylinder(h=text_thickness, d=6, $fn=50);
                }
        }
    }
}