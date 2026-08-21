// ============================================================
// 奥克斯(AUX)饮水机杯垫 —— 环形版 (独立文件, 实心版见 饮水机杯垫.scad)
// 外尺寸: 101 x 81 x 15.5 mm (与实心版一致, 保持不变)
// 竖边圆角 R = 25, 壁厚 WALL = 2 mm (内腔自动带 R = 23 圆角)
// 顶/底棱边 45° 倒角, 默认 0.5mm
//   注意: 环形时倒角须 < 壁厚的一半 (1mm) 才能保留平顶;
//         WALL = 0 退回实心; CHAMFER = 0 取消倒角
// ============================================================

$fn = 128;

W = 101;        // 长 (X)
D = 81;         // 宽 (Y)
H = 15.5;       // 高 (Z)
R = 25;         // 竖边圆角半径

WALL = 2;       // 壁厚 (0 = 实心)
CHAMFER = 0;  // 顶/底棱边倒角尺寸 (0 = 不倒角)
E = 0.02;       // 微小过切, 避免共面

// ------------------------------------------------------------
// 带圆角的矩形截面
// ------------------------------------------------------------
module rounded_rect_profile(size_w, size_d, radius) {
    offset(r = radius) offset(r = -radius)
        square([size_w, size_d], center = true);
}

module profile_outer() { rounded_rect_profile(W, D, R); }
module profile_inner() { offset(r = -WALL) profile_outer(); }

// ------------------------------------------------------------
// 主体: 外轮廓拉伸, 减去内腔
// ------------------------------------------------------------
module body() {
    if (WALL <= 0) {
        linear_extrude(height = H, center = true) profile_outer();
    } else {
        difference() {
            linear_extrude(height = H, center = true) profile_outer();
            linear_extrude(height = H + 2*E, center = true) profile_inner();
        }
    }
}

// ------------------------------------------------------------
// 外沿 45° 倒角楔块 (axis: "X"/"Y" 截面所在侧面; sign: ±1; top: 顶/底)
// 斜边严格通过 (i, 顶面) 与 (f, 顶面-CHAMFER), 保证 45°
// ------------------------------------------------------------
module wedge(axis, sign, top) {
    if (axis == "Y") {
        f = sign * D/2;                          // 外沿面位置
        i = f - sign * CHAMFER;                  // 顶面内缩点
        rotate([0, 90, 0])                       // 截面在 YZ 平面, 沿 X 拉伸
            linear_extrude(W + 4 * CHAMFER, center = true)
                polygon(top ? [
                    [-H/2,           i],
                    [-H/2 + CHAMFER, f],
                    [-H/2 - E,       f],
                    [-H/2 - E,       i]
                ] : [
                    [ H/2,           i],
                    [ H/2 - CHAMFER, f],
                    [ H/2 + E,       f],
                    [ H/2 + E,       i]
                ]);
    } else {
        f = sign * W/2;
        i = f - sign * CHAMFER;
        rotate([90, 0, 0])                       // 截面在 XZ 平面, 沿 Y 拉伸
            linear_extrude(D + 4 * CHAMFER, center = true)
                polygon(top ? [
                    [i,  H/2],
                    [f,  H/2 - CHAMFER],
                    [f,  H/2 + E],
                    [i,  H/2 + E]
                ] : [
                    [i, -H/2],
                    [f, -H/2 + CHAMFER],
                    [f, -H/2 - E],
                    [i, -H/2 - E]
                ]);
    }
}

// ------------------------------------------------------------
// 内腔 45° 倒角切块(棱锥台): 从内轮廓(z=zMid) 到扩大 CHAMFER 的
// 轮廓(z=zExt)。横截面随高度线性过渡, 自动跟随四角圆弧,
// 不会在角部留下台阶。
// ------------------------------------------------------------
module plug(top) {
    s = top ? 1 : -1;
    zMid = s*(H/2) - s*CHAMFER;
    zExt = s*(H/2) + s*E;
    hull() {
        translate([0, 0, zMid])
            linear_extrude(0.001, center = true) profile_inner();
        translate([0, 0, zExt])
            linear_extrude(0.001, center = true) offset(r = CHAMFER) profile_inner();
    }
}

// ------------------------------------------------------------
// 成品
// ------------------------------------------------------------
module coaster() {
    if (CHAMFER <= 0) {
        body();
    } else {
        difference() {
            body();
            // 外沿: 四边 x 顶/底
            for (s = [1, -1]) {
                for (top = [true, false]) {
                    wedge("Y", s, top);
                    wedge("X", s, top);
                }
            }
            // 内腔: 顶/底各一个棱锥台
            if (WALL > 0) {
                plug(true);
                plug(false);
            }
        }
    }
}

coaster();
