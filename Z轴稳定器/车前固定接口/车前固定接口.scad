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

// 延长臂 (两段式)
ARM_W      = 20;     // 臂宽 (X) —— 独立设置
ARM_T      = 12;     // 臂厚 (Y) —— 独立设置
ARM_OFFSET = 14;     // 上段相对底座的水平偏移(向猪鼻侧 +Y)
ARM_BEND   = 20;     // 下段(平滑连接段)高度 (Z)
ARM_VERT   = 20;     // 上段(末段直臂)长度 (沿 ARM_TIP_ANGLE 方向)
ARM_TIP_ANGLE = 60;  // 上段最终倾角(与水平面夹角, °): 90=垂直(当前状态), 0=水平
ARM_CURVE  = 0.6;    // 下段贝塞尔转折力度 0~1(越大越平缓; 影响连接段形状, 不影响端点)
ARM_DIR    = +1;     // +1 = 向 +Y(远离螺丝座=猪鼻环侧); -1 = 反向
FC         = 64;     // 扫描细分段数(越大越平滑)

// M5 间隙孔半径
RH = HOLE_D/2;

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

// ========== 延长臂: 下段(平滑连接) + 上段(固定倾角直臂) ==========
// 上段: 直臂, 起点 S=(ARM_OFFSET, BASE_H+ARM_BEND), 方向角 = ARM_TIP_ANGLE(与水平面夹角), 长 ARM_VERT。
// 下段: 三次 Bézier 从底座顶 P0=(0,BASE_H)(切向竖直 +Z)平滑过渡到 S;
//       末端切向 = (cos TIP, sin TIP) = 上段切向, 故两端无折角。横向偏移由 ARM_OFFSET 决定。
// 截面从底座(BASE_W x BASE_T)沿下段平滑过渡到臂(ARM_W x ARM_T), 上段保持臂截面。
// 注意: 本 OpenSCAD 的 cos/sin/atan2 以"度"为单位(cos(90)=0)。
function _ease(u) = (u >= 1) ? 1 : (u <= 0 ? 0 : (1 - cos(180*u))/2);
// 三次 Bézier 点(2D, (y,z) 平面)
function _bez(p0,c1,c2,p3,u) =
    let(v = 1-u,
        a = v*v*v, b = 3*v*v*u, c = 3*v*u*u, d = u*u*u)
    [a*p0[0]+b*c1[0]+c*c2[0]+d*p3[0],
     a*p0[1]+b*c1[1]+c*c2[1]+d*p3[1]];
// 三次 Bézier 切线(2D)
function _bezd(p0,c1,c2,p3,u) =
    let(v = 1-u,
        a = 3*v*v, b = 6*v*u, c = 3*u*u)
    [a*(c1[0]-p0[0])+b*(c2[0]-c1[0])+c*(p3[0]-c2[0]),
     a*(c1[1]-p0[1])+b*(c2[1]-c1[1])+c*(p3[1]-c2[1])];

module arm() {
    N  = FC;
    tip= ARM_TIP_ANGLE;
    // ---- 下段(连接段)端点/控制点 ----
    p0 = [0, BASE_H];                       // 底座顶, 切向竖直(+Y? 不, +Z; 用 (y,z)=(0,BASE_H))
    p3 = [ARM_DIR*ARM_OFFSET, BASE_H + ARM_BEND];   // 上段起点
    // 切向: 起点竖直(0,+1); 终点 = (cosTIP, sinTIP) 同方向于上段
    h  = ARM_CURVE * sqrt(pow(ARM_OFFSET,2) + pow(ARM_BEND,2))/2 + 1e-9;
    c1 = [p0[0], p0[1] + h];                // 切向竖直
    c2 = [p3[0] - h*cos(tip), p3[1] - h*sin(tip)]; // 切向 = tip
    for(i=[0:N-1]) {
        u0 = i/N; u1 = (i+1)/N; uc = (u0+u1)/2;
        pp = _bez(p0, c1, c2, p3, uc);
        dd = _bezd(p0, c1, c2, p3, uc);
        th = atan2(dd[0], dd[1]);           // 切线相对 +Z 的倾角(度)
        e  = _ease(uc);
        w  = BASE_W + (ARM_W - BASE_W)*e;
        tt = BASE_T + (ARM_T - BASE_T)*e;
        L  = 2.6 * sqrt(pow(p3[0]-p0[0],2)+pow(p3[1]-p0[1],2)) / N;
        translate([0, pp[0], pp[1]])
            rotate([-th, 0, 0])
            cube([w, tt, L], center=true);
    }
    // ---- 上段(固定倾角直臂) ----
    dir  = [cos(tip), sin(tip)];            // (y,z) 平面方向
    ds   = ARM_VERT/N;
    for(i=[0:N-1]) {
        s  = (i+0.5)*ds;
        yy = ARM_DIR*ARM_OFFSET + dir[0]*s;
        zz = (BASE_H + ARM_BEND) + dir[1]*s;
        th = atan2(dir[0], dir[1]);         // 恒 = 90-tip? 相对 +Z
        translate([0, yy, zz])
            rotate([-th, 0, 0])
            cube([ARM_W, ARM_T, 2.6*ds], center=true);
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
