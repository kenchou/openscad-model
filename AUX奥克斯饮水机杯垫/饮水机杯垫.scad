// ============================================================
// 奥克斯(AUX)饮水机杯垫 —— 实心版
// 尺寸: 101 x 81 x 15.5 mm
// 四个竖边圆角 R = 25 (顶面、底面保持平面)
// 顶/底棱边 45° 倒角(默认 2mm, 设为 0 可取消)
// ============================================================

$fn = 128;

W = 101;        // 长 (X)
D = 81;         // 宽 (Y)
H = 15.5;       // 高 (Z)
R = 25;         // 竖边圆角半径

CHAMFER = 0;    // 顶/底棱边倒角尺寸 (0 = 不倒角)
E = 0.02;       // 微小过切, 避免与顶/底面共面

// ------------------------------------------------------------
// 带圆角的矩形截面(四角 R25)
// 思路: 先向内收缩 R, 再向外扩张 R,
//       直角被"削"成半径 R 的圆弧, 直边位置不变。
// ------------------------------------------------------------
module profile() {
    offset(r = R) offset(r = -R)
        square([W, D], center = true);
}

// 主体: 截面沿 Z 拉伸 -> 竖边自然带 R25 圆角, 顶/底是平面
module body() {
    linear_extrude(height = H, center = true)
        profile();
}

// ------------------------------------------------------------
// 45° 倒角楔块: 截面是直角三角形, 位于某一侧面, 沿另一水平轴拉伸。
// axis: "X" 或 "Y" —— 截面所在侧面;  sign: +1 / -1 侧面方向
// top : true 顶部棱边 / false 底部棱边
// 多边形坐标: (第一维 = 拉伸方向坐标, 第二维 = 世界 Z)
// ------------------------------------------------------------
module wedge(axis, sign, top) {
    if (axis == "Y") {
        // 截面在 YZ 平面, 沿 X 拉伸: rotate([0,90,0]) 下
        // 世界坐标 = (0, 多边形Y, -多边形X)
        rotate([0, 90, 0])
            linear_extrude(W + 4 * CHAMFER, center = true)
                polygon(top ? [
                    [-H/2 - E,            sign * (D/2 - CHAMFER)],
                    [-H/2 + CHAMFER + E,  sign *  D/2],
                    [-H/2 - E,            sign *  D/2]
                ] : [
                    [ H/2 + E,            sign * (D/2 - CHAMFER)],
                    [ H/2 - CHAMFER - E,  sign *  D/2],
                    [ H/2 + E,            sign *  D/2]
                ]);
    } else {
        // 截面在 XZ 平面, 沿 Y 拉伸: rotate([90,0,0]) 下
        // 世界坐标 = (多边形X, 0, 多边形Y)
        rotate([90, 0, 0])
            linear_extrude(D + 4 * CHAMFER, center = true)
                polygon(top ? [
                    [sign * (W/2 - CHAMFER),  H/2 + E],
                    [sign *  W/2,             H/2 - CHAMFER - E],
                    [sign *  W/2,             H/2 + E]
                ] : [
                    [sign * (W/2 - CHAMFER), -H/2 - E],
                    [sign *  W/2,            -H/2 + CHAMFER + E],
                    [sign *  W/2,            -H/2 - E]
                ]);
    }
}

// 成品: 主体减去四边顶部 + 四边底部的倒角楔块
module coaster() {
    if (CHAMFER <= 0) {
        body();
    } else {
        difference() {
            body();
            for (s = [1, -1]) {
                wedge("Y", s, true);   wedge("Y", s, false);
                wedge("X", s, true);   wedge("X", s, false);
            }
        }
    }
}

coaster();
