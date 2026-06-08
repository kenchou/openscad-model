// 减震脚垫 - 蜂窝底部版本 - BOSL2
// 用于卡入圆柱形脚，底部蜂窝状六边形减震槽

include <BOSL2/std.scad>

// ============================================
// 用户定制参数
// ============================================
FOOT_DIA = 11.5;
FOOT_H = 7;
WALL = 2.5;
LOWER_D = 22;
TOTAL_H = 12;

// ============================================
// 高级参数
// ============================================
CLEARANCE = 0.2;
BASE = 3;
SECTION_H = TOTAL_H / 3;

// 减震槽参数 (窄槽防止打印悬空)
HEX_SIZE = 2.5;      // 六边形大小
SLOT_WIDTH = 0.4;    // 目标槽宽 (最终效果)
SLOT_DEPTH = 0.6;    // 槽深度
RIM_WIDTH = 2;       // 外圈圆环宽度
RING_SLOT_D = 0.8;   // 侧面环槽直径

// 六边形边框宽度 = 槽宽的一半 (因为相邻边合并)
HEX_EDGE_WIDTH = SLOT_WIDTH / 2;

// 倒角参数
CHAMFER_H = 1.5;
CHAMFER_EXPAND = 3;

// ============================================
// 自动计算
// ============================================
INNER_D = FOOT_DIA + CLEARANCE * 2;
UPPER_D = INNER_D + WALL * 2;
INNER_TOP_D = INNER_D + CHAMFER_EXPAND;

UPPER_H = SECTION_H;
TRANSITION_H = SECTION_H;
LOWER_H = SECTION_H;
TRANSITION_END_Z = LOWER_H + TRANSITION_H;

CAVITY_START_Z = BASE;
CAVITY_END_Z = TOTAL_H - CHAMFER_H;
CAVITY_H = CAVITY_END_Z - CAVITY_START_Z;

// 底部槽尺寸
ring_center_d = LOWER_D - RIM_WIDTH * 2;
ring_inner_r = (ring_center_d - SLOT_WIDTH) / 2;

// ============================================
// 模块：六边形边框 (槽) - 边框宽度为槽宽的一半
// ============================================
module hex_outline(size, edge_width) {
    difference() {
        rotate(30) circle(r=size, $fn=6);
        rotate(30) circle(r=size - edge_width, $fn=6);
    }
}

// ============================================
// 主体建模
// ============================================
difference() {
    // === 外形 ===
    union() {
        cylinder(h=LOWER_H, d=LOWER_D, $fn=128);
        translate([0, 0, LOWER_H])
        cylinder(h=TRANSITION_H, d1=LOWER_D, d2=UPPER_D, $fn=128);
        translate([0, 0, TRANSITION_END_Z])
        cylinder(h=UPPER_H, d=UPPER_D, $fn=128);
    }
    
    // === 内腔 + 顶部喇叭口 ===
    union() {
        translate([0, 0, CAVITY_START_Z])
        cylinder(h=CAVITY_H + 0.5, d=INNER_D, $fn=128);
        translate([0, 0, TOTAL_H - CHAMFER_H])
        cylinder(h=CHAMFER_H, d1=INNER_D, d2=INNER_TOP_D, $fn=128);
    }
    
    // === 侧面环槽 ===
    for(i = [1:4]) {
        z = TRANSITION_END_Z + i * UPPER_H / 5;
        translate([0, 0, z])
        rotate_extrude($fn=128)
        translate([UPPER_D/2 - RING_SLOT_D/2, 0])
        circle(d=RING_SLOT_D);
    }
    
    // === 底部环形槽 ===
    difference() {
        cylinder(h=SLOT_DEPTH, d=ring_center_d + SLOT_WIDTH, $fn=128);
        cylinder(h=SLOT_DEPTH, d=ring_center_d - SLOT_WIDTH, $fn=128);
    }
    
    // === 底部蜂窝网格槽 (六边形边框) ===
    linear_extrude(h=SLOT_DEPTH) {
        intersection() {
            // 圆形区域
            circle(r=ring_inner_r, $fn=128);
            
            // 六边形边框阵列 (边框宽 = 槽宽/2)
            hex_spacing_y = HEX_SIZE * 1.5;
            hex_spacing_x = HEX_SIZE * sqrt(3);
            rows = ceil(ring_inner_r / hex_spacing_y) + 2;
            
            for(row = [-rows : rows]) {
                y = row * hex_spacing_y;
                x_offset = (abs(row) % 2 == 1) ? hex_spacing_x / 2 : 0;
                cols = ceil(ring_inner_r / hex_spacing_x) + 2;
                
                for(col = [-cols : cols]) {
                    x = col * hex_spacing_x + x_offset;
                    translate([x, y])
                    hex_outline(HEX_SIZE, HEX_EDGE_WIDTH);
                }
            }
        }
    }
}

// ============================================
// 参考脚
// ============================================
// color("blue", alpha=0.3) {
//     translate([0, 0, TOTAL_H - FOOT_H])
//     cylinder(h=FOOT_H, d=FOOT_DIA, $fn=128);
// }
