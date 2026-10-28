// ============================================================
//  六棱柱收纳框架(7 格蜂窝)
//  · 每格宽度 = 六棱柱的对边距(左右两条平边之间的距离)
//  · 格与格之间、以及最外圈,壁厚统一
//  · 外形 = 7 格蜂窝整体外扩一个壁厚;零件外露的上下棱边再按 EDGE_R 倒圆(容器内部保持直角)
//  · 定制参数集中在文件末尾
// ============================================================

// 单个格子截面:尖角朝上/下,左右为平边(平边距 = 六棱柱对边宽)
module hex_cell_2d() {
    rotate([0, 0, 30])                  // $fn=6 的圆默认平边朝上下,转 30° 改为尖角朝上下
        circle(r = CELL_W / sqrt(3), $fn = 6);
}

// 7 个格子截面的并集:中心 1 个 + 周围 6 个
module honeycomb_2d() {
    union()
        for (p = CELL_POS)
            translate(p) hex_cell_2d();
}

// 零件外轮廓截面(2D):蜂窝外形整体外扩一个壁厚;inset > 0 时向内收缩(用于棱边倒圆)
module outer_2d(inset) {
    offset(r = -inset) offset(r = WALL, $fn = 64) honeycomb_2d();
}

// 棱边圆角:t = 距该端面的距离,返回此处外轮廓的内缩量(1/4 圆;t = 0 在端面上)
function edge_fil(t) =
    let (u = min(max(t, 0), EDGE_R))
        EDGE_R - sqrt(max(0, EDGE_R * EDGE_R - (EDGE_R - u) * (EDGE_R - u)));

// 棱边倒圆的"切除环":在 z 高度处切掉外轮廓外侧一圈,环宽 = 该层的内缩量
// 用逐层减法而不是 hull() —— 蜂窝外轮廓是凹多边形, hull() 取凸包会把凹口填平
module edge_round_cut(z, dz, inset) {
    translate([0, 0, z])
        linear_extrude(height = dz + 0.01, convexity = 10)
            difference() {
                outer_2d(0);
                outer_2d(inset);
            }
}

// 外轮廓实体:上下棱边按 EDGE_R 倒圆(逐层阶梯近似 1/4 圆;层用平方分布,越靠端面越密,台阶宽度才均匀)
module outer_solid() {
    difference() {
        linear_extrude(height = THICK, convexity = 10) outer_2d(0);
        for (i = [0 : EDGE_STEPS - 1]) {
            t0 = EDGE_R * (i / EDGE_STEPS) * (i / EDGE_STEPS);          // 距端面的距离
            t1 = EDGE_R * ((i + 1) / EDGE_STEPS) * ((i + 1) / EDGE_STEPS);
            edge_round_cut(THICK - t1, t1 - t0, edge_fil(t0));          // 顶部棱边
            if (!HAS_BOTTOM)                                            // 没有底时,零件底面也要倒圆
                edge_round_cut(t0, t1 - t0, edge_fil(t0));
        }
    }
}

// 框架:外轮廓实体挖去 7 个直壁格子(容器内部保持直角)
module frame() {
    difference() {
        outer_solid();
        for (p = CELL_POS)
            translate([p[0], p[1], 0])
                linear_extrude(height = THICK + 0.02, convexity = 10) hex_cell_2d();
    }
}

// 底板(可选):与框架外形相同的一层薄板,底部棱边同样倒圆
module bottom_plate() {
    R1 = min(EDGE_R, BOTTOM_T);
    difference() {
        linear_extrude(height = BOTTOM_T, convexity = 10) outer_2d(0);
        for (i = [0 : EDGE_STEPS - 1]) {
            t0 = R1 * (i / EDGE_STEPS) * (i / EDGE_STEPS);
            t1 = R1 * ((i + 1) / EDGE_STEPS) * ((i + 1) / EDGE_STEPS);
            edge_round_cut(t0, t1 - t0, edge_fil(t0));
        }
    }
}

// 装配:底 + 框架(整体底面落在 z=0)
module assembly() {
    if (HAS_BOTTOM) bottom_plate();
    translate([0, 0, HAS_BOTTOM ? BOTTOM_T : 0]) frame();
}

// 预览剖切:把 PREVIEW_CUT 改成 true 再按 F5,可直接看到剖面(检查壁厚 / 底板 / 棱边圆角用)
if (PREVIEW_CUT)
    difference() {
        assembly();
        translate([-300, -300, -5]) cube([600, 300, 600]);   // 切掉前半
        translate([-300, -300, 14]) cube([600, 600, 600]);   // 再切掉 14mm 以上
    }
else
    assembly();

// ==================== 定制参数 ====================
CELL_W = 18;        // 每格宽:六棱柱的对边距(左右两条平边之间的距离)
WALL   = 1.8;       // 间隔墙厚(中间隔墙与外框同一厚度)
THICK  = 80;         // 框架厚度(六棱柱插入方向的高度)

HAS_BOTTOM = true;  // 是否生成底:true = 框架下面加一层封底,false = 只有框架
BOTTOM_T   = 1.2;   // 底的厚度(仅 HAS_BOTTOM = true 时生效)

EDGE_R     = 1.0;   // 零件外露棱边的圆角半径(外轮廓的上/下边缘);需 ≤ WALL(=1.8) 且 ≤ BOTTOM_T(=1.2)
EDGE_STEPS = 12;    // 棱边圆角的细分层数(10~16;层用平方分布,靠端面自动加密,台阶宽度均匀)

PREVIEW_CUT = false; // 预览剖切开关:true = 切掉前半 + 只留底部 14mm,方便看剖面;★导出 STL 前改回 false★

CELL_PITCH = CELL_W + WALL;                 // 相邻两格的中心距
CELL_POS = [                                // 蜂窝排布:中心 1 + 周围 6(尖角朝上)
    [0, 0],
    [ CELL_PITCH, 0],                         [-CELL_PITCH, 0],
    [ CELL_PITCH / 2,  CELL_PITCH * sin(60)], [-CELL_PITCH / 2,  CELL_PITCH * sin(60)],
    [ CELL_PITCH / 2, -CELL_PITCH * sin(60)], [-CELL_PITCH / 2, -CELL_PITCH * sin(60)],
];
