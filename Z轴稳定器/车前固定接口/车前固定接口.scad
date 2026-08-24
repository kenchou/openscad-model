// 车前固定接口 (Z轴稳定器 / 大行P8猪鼻转换底座抱箍)
// 坐标系: X=底座宽方向(正视图水平), Y=厚度方向(正视图纵深, M5孔沿此方向贯穿),
//          Z=竖直向上(底座高度方向)。整体在 X、Y 向居中。
// 底座: 20(宽) x 16(厚) x 80(高), 中央开竖槽(槽顶 z=BASE_H-SLOT_FROM_TOP), 底面开口竖直上插,
//       把抱箍螺丝座板(≈8宽 x 8厚)包入槽内增加稳定性。
// 延长臂: 截面独立(ARM_W x ARM_T), 从底座顶向"猪鼻环一侧"(+Y)平滑 S 形弯上, 末端竖直向上。
// M5孔距有二义性(12.5/25 或 13.2/26.4), 孔1 做成竖向短槽留旷量, 孔2/孔3 为竖向长槽。

// ========== 可调参数 ==========
BASE_W   = 20;      // 底座宽 (X), 正视图水平
BASE_T   = 16;      // 底座厚 (Y)
BASE_H   = 80;      // 底座高 (Z)

SLOT_W   = 9;       // 竖槽宽 (X)  —— 抱箍板宽 8, 留 1 旷量防 PETG 收缩
SLOT_D   = 8;       // 竖槽深 (Y)  —— 前侧挖去 8, 留 8 厚背壁
SLOT_FROM_TOP = 30; // 槽顶距底座顶距离
SLOT_TOP = BASE_H - SLOT_FROM_TOP;           // 槽顶 z(=50), 高于此处实体, 底面开口

HOLE_D   = 5.5;     // M5 间隙孔直径
HOLE1_TOP_GAP = 2.45; // 孔1 上弧边距槽顶的实测距离 (有测量误差)
HOLE1_EXT = 0.6;    // 孔1 竖槽两端额外余量(mm), 覆盖 2.45 的测量误差
HOLE_GAP13 = 25;    // 孔1 - 孔3 名义间距(mm)
HOLE_GAP12 = 13.2;  // 孔1 - 孔2 名义间距(mm)
HOLE_ALT13 = 26.4;  // 孔1 - 孔3 备选间距(若三孔等分)
HOLE_ALT12 = 12.5;  // 孔1 - 孔2 备选间距(若三孔等分)
SLOT_EXT   = 0.6;   // 孔槽两端额外余量(mm)

// 延长臂
ARM_W      = 20;     // 臂宽 (X) —— 独立设置
ARM_T      = 12;     // 臂厚 (Y) —— 独立设置
ARM_OFFSET = 14;    // 臂向猪鼻侧(+Y)的水平偏移
ARM_BEND   = 20;    // 弯段高度(mm): 底座顶 → 竖直段起点 的平滑过渡
ARM_VERT   = 20;    // 臂端竖直直臂长度(mm)
ARM_DIR    = +1;    // +1 = 向 +Y(远离螺丝座=猪鼻环侧); -1 = 反向
FC         = 64;    // 扫描细分段数(越大越平滑)

// 臂顶 z(总高)= 底座高 + 弯段高 + 竖直段长
ARM_TOP    = BASE_H + ARM_BEND + ARM_VERT;
RH = HOLE_D/2;      // M5 间隙孔半径

// ========== 底座(居中于 x=0, y=0; 0..BASE_H) ==========
// 竖槽: z∈[0, SLOT_TOP] 底面开口; X 居中宽 SLOT_W; 前侧(-Y)挖 SLOT_D, 留背部 SLOT_D 厚壁。
module base() {
    difference() {
        translate([0, 0, BASE_H/2]) cube([BASE_W, BASE_T, BASE_H], center=true);
        // 槽体: 从底面(z=0)开口向上到 SLOT_TOP; 贴前侧 -Y 面挖 SLOT_D
        translate([0, -(BASE_T/2) + SLOT_D/2, SLOT_TOP/2])
            cube([SLOT_W, SLOT_D, SLOT_TOP], center=true);
    }
}

// ========== 底座上的 3 颗 M5 孔 ==========
// 按槽顶(SLOT_TOP)定位: 孔1 上弧边距槽顶 = HOLE1_TOP_GAP。
module vh_slot(zc, len) {
    // 沿 Z 的竖向长槽, 贯穿 Y; 槽宽=X 方向 HOLE_D, 槽总高 = len + HOLE_D
    translate([0,0,zc])
    rotate([90,0,0])
    hull() {
        translate([0,0,  len/2]) cylinder(r=RH, h=BASE_T+2, center=true);
        translate([0,0, -len/2]) cylinder(r=RH, h=BASE_T+2, center=true);
    }
}

module holes() {
    z1 = SLOT_TOP - HOLE1_TOP_GAP - RH;   // 孔1 中心 z(=槽顶 - 2.45 - 2.75 ≈ 44.8)
    // 孔1: 竖向短槽(留旷量)
    vh_slot(z1, 2*HOLE1_EXT);
    // 孔2
    z2n = z1 - HOLE_GAP12;
    z2a = z1 - HOLE_ALT12;
    vh_slot((z2n+z2a)/2, abs(z2n-z2a) + 2*SLOT_EXT);
    // 孔3
    z3n = z1 - HOLE_GAP13;
    z3a = z1 - HOLE_ALT13;
    vh_slot((z3n+z3a)/2, abs(z3n-z3a) + 2*SLOT_EXT);
}

// ========== 延长臂: S 形弯段 + 顶端竖直直臂段 ==========
// 中心线 y(t)=ARM_OFFSET*(1-cos(180t))/2 (度制), z(t)=BASE_H+(ARM_TOP-BASE_H)*t。
// 截面从底座截面(BASE_W x BASE_T)平滑过渡到臂截面(ARM_W x ARM_T), 余弦缓动。
// 注意: 本 OpenSCAD 的 cos/sin/atan2 以"度"为单位(cos(90)=0)。
function _cy(z, zc0, zb0, off0) = (z <= zb0)
    ? off0 * (1 - cos(180 * (z - zc0)/(zb0 - zc0))) / 2
    : off0;
function _ease(u) = (u >= 1) ? 1 : (u <= 0 ? 0 : (1 - cos(180*u))/2);

module arm() {
    N  = FC;
    ZB = BASE_H + ARM_BEND;            // 弯段顶 = 竖直段起点
    for(i=[0:N-1]) {
        z0 = BASE_H + (ARM_TOP - BASE_H) * i/N;
        z1 = BASE_H + (ARM_TOP - BASE_H) * (i+1)/N;
        zc = (z0 + z1)/2;
        yy = ARM_DIR * _cy(zc, BASE_H, ZB, ARM_OFFSET);
        dyf = _cy(z1, BASE_H, ZB, ARM_OFFSET) - _cy(z0, BASE_H, ZB, ARM_OFFSET);
        dzf = z1 - z0;
        th  = atan2(dyf, dzf);         // 切线相对 +Z 的倾角(度)
        // 截面随弯段平滑过渡: BASE -> ARM
        u  = (zc - BASE_H) / max(ARM_BEND, 1e-9);
        e  = _ease(u);
        w  = BASE_W + (ARM_W - BASE_W)*e;
        th2= BASE_T + (ARM_T - BASE_T)*e;
        L  = 2.6*(ARM_TOP - BASE_H)/N; // 每段长度(稍重叠保证连续)
        translate([0, yy, zc])
            rotate([-th, 0, 0])        // 绕 X 旋转, 使本段沿切线方向
            cube([w, th2, L], center=true);
    }
}

// ========== 合成 ==========
difference() {
    union() {
        base();
        arm();
    }
    holes();
}
