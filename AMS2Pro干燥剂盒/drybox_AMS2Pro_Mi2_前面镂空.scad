// drybox_AMS2Pro_Mi2_前面镂空.scad
// 变体(独立新文件, 不覆盖原 drybox_AMS2Pro_Mi2.stl):
// 把前面(实心面板, y≈14.7)做成与背面(y≈41.0)一致的镂空网格。
//
// 几何依据(实测原始 STL):
//   - 前面实心面板: y∈[14.7,15.7], 覆盖 x 全宽、z 约 [16,60](面板平直区)。
//   - 背面网格面板: y∈[39.5,41.0]  ->  与前面 26.3mm 距离(41.0-14.7=26.3)。
//   - 镂空图案(背面/侧面一致)= 交错(staggered)竖槽网格:
//       槽宽 ~0.9mm(x), 槽高 ~10.9mm(z), 列距 2mm(x), 行距 12mm(z),
//       相邻列(奇偶)在 z 向错开 ~5.5mm(双相位)。
//
// 实现: 生成与背面相同的交错竖槽切刀, 沿 y 切透前面板。

F = 90;                      // 圆度
FRONT_Y = 14.7;              // 前面板外表面
PANEL_T = 1.0;               // 前面板厚(实测约 1.0)
CUT_Y0 = FRONT_Y - 0.7;      // 切刀 y 下界(前面留一点, 保证切透且不切前侧别的面)
CUT_Y1 = FRONT_Y + PANEL_T + 0.7; // 切刀 y 上界(穿进内腔一点, 空腔无碍)
CUT_YMID = (CUT_Y0 + CUT_Y1) / 2; // 切刀 y 中心(cylinder 用 center=true)
CUT_YH = CUT_Y1 - CUT_Y0;    // 切刀 y 厚度

// 网格窗口: 只在前面板平直区(避开边框、圆角、上下唇边)打孔
MESH_X0 = 3.5; MESH_X1 = 41.0;
MESH_Z0 = 16.0; MESH_Z1 = 60.0;

SLOT_W = 0.9;                // 槽宽 (x)
SLOT_H = 10.9;               // 槽高 (z)
COL_PITCH = 2.0;             // 列距 (x)
ROW_PITCH = 12.0;            // 行距 (z)
PHASE_OFF = 5.5;             // 奇偶列 z 向错位 (双相位)

// 每个竖槽 = 沿 z 拉伸的圆头(stadium)切刀
module slot(xc, zc) {
    halfH = (SLOT_H - SLOT_W) / 2;
    hull() {
        translate([xc, CUT_YMID, zc - halfH]) rotate([90, 0, 0]) cylinder(r = SLOT_W / 2, h = CUT_YH, center = true, $fn = F);
        translate([xc, CUT_YMID, zc + halfH]) rotate([90, 0, 0]) cylinder(r = SLOT_W / 2, h = CUT_YH, center = true, $fn = F);
    }
}

// 交错网格切刀集合
module mesh_cutters() {
    k = floor((MESH_X1 - 4.25) / COL_PITCH);   // 列索引 0..k, x=4.25+2*i
    for (i = [0 : k]) {
        xc = 4.25 + i * COL_PITCH;
        // 偶数列相位 A: z=2.62+12*m ; 奇数列相位 B: z=8.12+12*m (=2.62+5.5)
        zbase = 2.62 + (i % 2 == 0 ? 0 : PHASE_OFF);
        for (m = [-1 : 6]) {
            zc = zbase + m * ROW_PITCH;
            if (xc > MESH_X0 && xc < MESH_X1 && zc > MESH_Z0 && zc < MESH_Z1) {
                slot(xc, zc);
            }
        }
    }
}

// 剪切窗口: 限制在前面板平直区(不许切到边框/圆角/上下唇边)
module cutbox() {
    translate([(MESH_X0 + MESH_X1) / 2, (CUT_Y0 + CUT_Y1) / 2, (MESH_Z0 + MESH_Z1) / 2])
        cube([MESH_X1 - MESH_X0, CUT_Y1 - CUT_Y0, MESH_Z1 - MESH_Z0], center = true);
}

difference() {
    import("/Users/ken/Documents/OpenSCAD/AMS2Pro干燥剂盒/drybox_AMS2Pro_Mi2.stl");
    intersection() {
        mesh_cutters();
        cutbox();
    }
}
