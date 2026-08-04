// 米兔7充电支架 - 分体切割脚本
// 在底座与支架臂交界处切割，通过螺丝组合

// ===== 参数 =====
cut_z = 7.0;           // 切割面Z高度（底座与支架臂交界处，Z=6.5~7过渡）
screw_w = 3.2;         // 螺丝通孔六角对边距（M3 = 3.2mm）
head_w = 6.0;          // 沉头孔六角对边距（M3沉头螺丝头约6mm）
head_h = 3.0;          // 沉头孔深度
pilot_w = 2.5;         // 导孔六角对边距（M3自攻螺丝底孔）
arm_x_min = -2;        // 支架臂X裁剪范围（排除底座横部）
arm_x_max = 5.5;
transition_h = 4;       // 过渡区高度（Z=cut_z ~ cut_z+transition_h做X裁剪）

// 螺丝位置（在XY平面上）
// 底座大约 X:0~70, Y:10~61
// 支架臂在 X:0~5, Y:10~61（Z=7处）
// 螺丝放在支架臂范围内：X中心约2.5, Y分布
screw_positions = [
    [2.5, 20, 0],   // 螺丝1: X中心, Y=20
    [2.5, 45, 0],   // 螺丝2: X中心, Y=45
];

// 螺母槽（如果使用嵌入螺母）
nut_d = 5.5;           // M2.5螺母对边距约5mm（实际M2.5螺母对边5mm）
nut_h = 2.5;           // 螺母厚度
nut_insert_d = 5.5;    // 嵌入螺母外径（热熔螺母约4.5-5mm）
// 注意：支架臂宽仅5mm，M2.5标准螺母可能过紧
// 建议使用M2螺丝或热熔螺母

// ===== 主程序 =====
module original_model() {
    import("米兔充电支架-凸出充电头.stl");
}

// 六角柱体：w=对边距, h=高度
module hex_cylinder(w, h) {
    cylinder(d = w / cos(30), h = h, $fn = 6);
}

// 下半部分（底座 + 螺丝孔）
module bottom_part() {
    difference() {
        // 底座：Z <= cut_z 的部分
        intersection() {
            original_model();
            translate([0, 0, -0.01])
                cube([100, 100, cut_z]);
        }
        // 螺丝通孔（盘头螺丝，螺丝头凸出底面）
        for (pos = screw_positions) {
            translate(pos)
                cylinder(d=screw_w, h=cut_z + 2, $fn=32);
        }
    }
}

// 上半部分（支架臂 + 导孔）
module top_part() {
    difference() {
        // 支架臂：Z >= cut_z，仅在底部过渡区做X裁剪，高处保留完整结构
        intersection() {
            original_model();
            translate([0, 0, cut_z])
                cube([100, 100, 60]);
            // 底部过渡区（Z=cut_z~cut_z+transition_h）：X裁剪切除底座残余
            // 高处：X不加限制，保留充电头等横向突出结构
            union() {
                // 过渡区：窄条
                translate([arm_x_min, -10, cut_z])
                    cube([arm_x_max - arm_x_min, 120, transition_h]);
                // 上部：保留完整宽度
                translate([-10, -10, cut_z + transition_h])
                    cube([100, 120, 50]);
            }
        }
        // 导孔（用于螺丝自攻）
        for (pos = screw_positions) {
            translate([pos[0], pos[1], cut_z - 1])
                hex_cylinder(pilot_w, 6);
        }
    }
}

// ===== 渲染 =====
// 在OpenSCAD GUI中预览时取消下面注释：
// bottom_part();
// top_part();
// 或完整预览：
// color("lightblue") bottom_part();
// color("lightgreen") translate([0, 0, cut_z]) top_part();
