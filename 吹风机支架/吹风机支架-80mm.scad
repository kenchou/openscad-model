include <BOSL2/std.scad>

module base() {
    difference() {
        cyl(d=BASE_DIA, h=BASE_H, anchor=BOTTOM);
        // 底板圆心标记（底面浅凹点）
        move([0, 0, -0.2]) cyl(d=CENTER_MARK_DIA, h=CENTER_MARK_DEPTH+0.2, anchor=BOTTOM, $fn=48);
        // 底板圆心标记（顶面浅凹点，与底面上下对应）
        move([0, 0, BASE_H-CENTER_MARK_DEPTH]) cyl(d=CENTER_MARK_DIA, h=CENTER_MARK_DEPTH+0.2, anchor=BOTTOM, $fn=48);
    }
}

module arms() {
    union() {
        difference(){
            tube(h=BRACKET_ARM_LEN, id=BARREL_OD, wall=WALL, anchor=BOTTOM);
            move([BRACKET_OFFSET, 0, WALL]) {
                // 侧放位置
                ycyl(h=BRACKET_ARM_LEN, d=BARREL_OD, anchor=BOTTOM);
                // 顶部开口
                move([2, 0, 0]) cuboid([BASE_DIA, BASE_DIA, BRACKET_ARM_LEN], rounding=2, anchor=BOTTOM+RIGHT);
                #move([15, 0, BRACKET_ARM_LEN]) cuboid([BASE_DIA, BASE_DIA, BRACKET_ARM_LEN], anchor=RIGHT);
            }
            // 手柄开口
            move([0,0,HANDLER_OFFSET]) union() {
                move([0,0, HANDLER_OD/2]) cube([50, HANDLER_OD, BRACKET_ARM_LEN], anchor=BOTTOM+LEFT);
                xcyl(h=50, d=HANDLER_OD, anchor=BOTTOM+LEFT);
            }
            // 线缆挂口
            # cut_cable_hook1();
            // 线缆挂钩2
            cut_cable_hook2();
        }
    }
}

module cut_cable_hook1() {
    move([CABLE_HOOK1_OFFSET, 0, BRACKET_ARM_LEN-8]) union() {
        ycyl(h=BRACKET_ARM_LEN, d=CABLE_OD);
        cube([CABLE_OD*3, BRACKET_ARM_LEN, CABLE_OD], anchor=RIGHT);
    }
}

module cut_cable_hook2() {
    move([CABLE_HOOK2_OFFSET, 0, BRACKET_ARM_LEN-8]) union() {
        #ycyl(h=BRACKET_ARM_LEN, d=CABLE_OD*1.5, anchor=RIGHT);
        #move([-CABLE_OD+2, 0, 0]) yrot(45) cuboid([CABLE_OD*3, BRACKET_ARM_LEN, CABLE_OD*1.5], rounding=2, anchor=RIGHT);
        move([-CABLE_OD+4, 0, 5]) cuboid([CABLE_OD, BRACKET_ARM_LEN, CABLE_OD], anchor=RIGHT);
    }
}

difference(){
    union() {
        base();
        move([0,0,5]) arms();
    }
    // 打印底面2
    //move([BASE_CUT, 0,0 ]) cube([100,100,100], anchor=BOTTOM+LEFT);
}

$fn=128;
BASE_DIA=88;    // 底座外径
BASE_H=5;   // 底座厚度
BASE_CUT=35; // 打印底面2位置
WALL=5; // 支架壁厚
BARREL_OD=78;   // 风筒外径
BRACKET_ARM_LEN=95; // 支架长度
BRACKET_OFFSET=-15; // 横向放置孔偏移量
HANDLER_OD=40;  // 手柄外径
HANDLER_OFFSET=15;  // 手柄距风筒后端最短距离
CABLE_OD=7; // 电源线缆外径
CABLE_HOOK1_OFFSET=5;
CABLE_HOOK2_OFFSET=30;
CENTER_MARK_DIA=1; // 底板圆心标记：直径
CENTER_MARK_DEPTH=0.2; // 底板圆心标记：深度