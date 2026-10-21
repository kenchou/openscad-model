include <BOSL2/std.scad>

module base() {
    cyl(d=BASE_DIA, h=BASE_H, anchor=BOTTOM);
}

module arms() {
    union() {
        difference(){
            union() {
                tube(h=BRACKET_ARM_LEN, id=BARREL_OD, wall=WALL, anchor=BOTTOM);
                //双臂加固连接
                difference() {
                    //move([32.95, 0, HANDLER_OD/2+WALL]) tilt(to=RIGHT) tube(id=HANDLER_OD, h=BRACKET_ARM_LEN, wall=WALL, anchor=BOTTOM);
                    move([35.45, 0, 0]) cube([WALL, 50, 50], anchor=BOTTOM);
                }
            }
            move([BRACKET_OFFSET, 0, WALL]) {
                // 侧放位置
                ycyl(h=BRACKET_ARM_LEN, d=BARREL_OD, anchor=BOTTOM);
                // 顶部开口
                cube([BASE_DIA, BASE_DIA, BRACKET_ARM_LEN], anchor=BOTTOM+RIGHT);
            }
            // 手柄开口
            union() {
                move([0,0, HANDLER_OD/2]) cube([BRACKET_ARM_LEN, HANDLER_OD, BRACKET_ARM_LEN], anchor=BOTTOM+LEFT);
                #xcyl(h=50, d=HANDLER_OD, anchor=BOTTOM+LEFT);
            }
            // 线缆挂口
            cut_cable_hook1();
            // 线缆挂钩2
            cut_cable_hook2();
        }
    }
}

module cut_cable_hook1() {
    move([BRACKET_OFFSET+5, 0, 90]) union() {
        #ycyl(h=BRACKET_ARM_LEN, d=CABLE_OD);
        cube([BARREL_OD, BRACKET_ARM_LEN, CABLE_OD], anchor=RIGHT);
    }
}

module cut_cable_hook2() {
    move([30, 0, 88]) union() {
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
    move([BASE_CUT, 0,0 ]) cube([100,100,100], anchor=BOTTOM+LEFT);
}

BASE_DIA=90;    // 底座外径
BASE_H=5;   // 底座厚度
BASE_CUT=35; // 打印底面2位置
WALL=5; // 支架壁厚
BARREL_OD=80;   // 风筒外径
BRACKET_ARM_LEN=95;
BRACKET_OFFSET=-15; // 横向放置孔偏移量
HANDLER_OD=45;  // 手柄外径
CABLE_OD=7; // 电源线缆外径