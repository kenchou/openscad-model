// ============================================================
// 奥克斯(AUX)饮水机杯垫 —— 内圈实体版 (独立文件)
// 尺寸 = 环形版内腔尺寸: 97 x 77 x 15.5 mm, 四角圆角 R = 23
// 顶/底保持平面; 可选 45° 倒角 (默认 0)
// 尺寸来源: 外圈 101x81 R25 - 壁厚 2mm -> 97x77 R23
// ============================================================

$fn = 128;

W = 97;         // 长 (X) = 101 - 2*壁厚
D = 77;         // 宽 (Y) = 81  - 2*壁厚
H = 15.5;       // 高 (Z)
R = 23;         // 圆角半径 = 25 - 壁厚

CHAMFER = 0;    // 顶/底棱边倒角尺寸 (0 = 不倒角)
E = 0.02;       // 微小过切, 避免共面

// ------------------------------------------------------------
// 带圆角的矩形截面
// ------------------------------------------------------------
module profile() {
    offset(r = R) offset(r = -R)
        square([W, D], center = true);
}

// 主体: 截面沿 Z 拉伸 -> 竖边带 R23 圆角, 顶/底是平面
module body() {
    linear_extrude(height = H, center = true)
        profile();
}

// ------------------------------------------------------------
// 外沿 45° 倒角楔块 (axis: "X"/"Y" 截面所在侧面; sign: ±1; top: 顶/底)
// 斜边严格通过 (i, 顶面) 与 (f, 顶面-CHAMFER), 保证 45°;
// E 只加在楔块外侧延伸角上, 不改变斜边角度。
// ------------------------------------------------------------
module wedge(axis, sign, top) {
    if (axis == "Y") {
        f = sign * D/2;                          // 侧面位置
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

// 成品: 主体减去四边顶部 + 四边底部的倒角楔块
module part() {
    if (CHAMFER <= 0) {
        body();
    } else {
        difference() {
            body();
            for (s = [1, -1]) {
                for (top = [true, false]) {
                    wedge("Y", s, top);
                    wedge("X", s, top);
                }
            }
        }
    }
}

part();
