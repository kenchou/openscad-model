// BYD秦（2014款）遥控钥匙保护套
// 从 STL 反求参数，rect_tube 容器 + 开窗

render_mode = "together"; // ["together","top","bottom","assembled"]

// 圆角半径：从STL反求 (45-32.37)/2
corner_r = 6.31;

wall_th = 1.3;
$fn = 64;

/* [上盖 - 矮壳7mm，底板双窗] */
top_w   = 45.0;
top_h   = 81.0;
top_z   = 7.0;
top_bot = 2.0;

// 窗口距左右9.38mm，距前后17.50mm，横条5.5mm
hole_xm = 9.38;
hole_ym = 17.50;
hole_b  = 5.5;

/* [下盖 - 高壳11.5mm] */
bot_w   = 45.0;
bot_h   = 81.0;
bot_z   = 11.5;
bot_bot = 1.5;

asm_gap = 0.2;

// ====================

module rounded_rect(w,h,r) {
    offset(r=r) square([w-2*r, h-2*r], center=true);
}

// rect_tube 容器
module rect_tube(w,h,total_z,bot,th,r,has_hole=false) {
    ir = max(r-th, 0.5);
    difference() {
        linear_extrude(total_z) rounded_rect(w,h,r);
        translate([0,0,bot])
            linear_extrude(total_z-bot+0.05)
                rounded_rect(w-2*th, h-2*th, ir);

        if (has_hole) {
            y0 = 134.5-157.5;
            y1 = 180.5-157.5;
            ww = w - 2*hole_xm;
            sub = ((y1-y0) - hole_b)/2;
            translate([0, y0+sub/2, -0.1])
                linear_extrude(bot+0.2)
                    square([ww,sub], center=true);
            translate([0, y1-sub/2, -0.1])
                linear_extrude(bot+0.2)
                    square([ww,sub], center=true);
        }
    }
}

module top_cover() {
    rect_tube(top_w,top_h,top_z,top_bot,wall_th,corner_r,has_hole=true);
}

module bottom_cover() {
    h = bot_h;
    w = bot_w;

    difference() {
        rect_tube(w,h,bot_z,bot_bot,wall_th,corner_r);

        // 侧窗：后侧墙(Y+壁, X-Z平面)，长条形
        // 右上角: 距右侧(X+)边缘10mm, 距顶1.58mm
        // 向X-延伸20mm, 向Z-延伸2mm, 贯穿Y壁厚
        translate([w/2-10-20, h/2-wall_th, bot_z-1.58-2])
            cube([20, wall_th, 2]);
    }
}

// ====================

if (render_mode=="together") {
    color("DodgerBlue",0.85) bottom_cover();
    translate([0,0,bot_z+asm_gap+top_z]) rotate([180,0,0])
        color("DodgerBlue",0.85) top_cover();
} else if (render_mode=="top") {
    color("DodgerBlue",0.85) top_cover();
} else if (render_mode=="bottom") {
    color("DodgerBlue",0.85) bottom_cover();
} else {
    translate([0,0,bot_z]) rotate([180,0,0])
        color("DodgerBlue",0.85) top_cover();
    color("LightBlue",0.7) bottom_cover();
}
