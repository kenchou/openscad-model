// 车前固定接口 (Z轴稳定器 / 大行P8猪鼻转换底座抱箍)
// 坐标系: X=底座宽方向(正视图水平), Y=厚度方向(正视图纵深, M5孔沿此方向贯穿),
//          Z=竖直向上(底座高度方向)。整体在 X、Y 向居中。
// 圆形连接件: include 圆形连接件.scad 的 circular_connector() 模块, 与底座/臂组合。
//            位置与朝向见下方 ---- 圆形连接件(热熔螺母接口) ---- 段, 由用户填写。
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

// 延长臂 (三段: 下段横移 + 主直臂(可倾斜) + 顶部件)
ARM_W      = 20;     // 臂宽 (X) —— 独立设置
ARM_T      = 16;     // 臂厚 (Y) —— 独立设置
ARM_OFFSET = 20;     // 臂相对底座的水平偏移(向猪鼻侧 +Y)
ARM_BEND   = 20;     // 下段(横移连接段)高度 (Z)
ARM_VERT   = 50;     // 主直臂长度 (mm), 方向由 ARM_MAIN_ANGLE 决定
ARM_MAIN_ANGLE = 75; // 主直臂倾角(与水平面夹角, °): 90=垂直(当前状态), <90 向+Y(猪鼻侧)倒
ARM_TIP_ANGLE = 120; // 顶部件倾角(与水平面夹角, °): 90=垂直(=主直臂的延续), >90 向-Y倒, <90 向+Y倒
ARM_TIP_LEN  = 25;   // 顶部件长度 (mm)
ARM_CURVE  = 0.6;    // 下段贝塞尔转折力度 0~1(越大越平缓)
ARM_DIR    = +1;     // +1 = 向 +Y(远离螺丝座=猪鼻环侧); -1 = 反向
FC         = 64;     // 扫描细分段数(越大越平滑)

// 圆形连接件(热熔螺母接口) —— 固定在顶部(用 ARM_TIP_ANGLE 控制臂顶角度), 方向固定
//   朝向: 盘面垂直X(圆盘在Y-Z平面), 凹点面朝 +X(右)、凸点面朝 −X(左), 中央孔沿X贯通。
//   放置: 圆盘中心 = 臂顶正上方。过渡 = 一个棱锥(大端=臂顶方截面, 小端=圆盘中心),
//         小端用"半径=圆盘半径(15)的圆柱"磨成凹圆弧 → 凹弧贴合圆盘外缘, 不侵入圆盘。
CONN_LIFT  = 22;    // 圆盘中心高出臂顶 z 的距离(mm): ≈ 圆盘半径15 + 臂厚半8 + 间隙; 圆盘下缘留出空隙
CONN_X     = 3.5;   // 圆盘中心 x(mm): 凹点面(x = 3.5 + 13/2 = 10)与臂右面(x=+10)齐平
CONN_R     = 15;    // 圆盘半径 & 磨圆柱半径 (= circular_connector 默认 R)
// ---- 连接件位置(内部计算, 不手动改) ----
_CMAIN = ARM_MAIN_ANGLE; _CTIP = ARM_TIP_ANGLE;
_CMD   = [ARM_DIR*cos(_CMAIN), sin(_CMAIN)];          // 主直臂方向 (y,z)
_CP3   = [ARM_DIR*ARM_OFFSET, BASE_H + ARM_BEND];      // 主臂起点
_CQ0   = [_CP3[0]+_CMD[0]*ARM_VERT, _CP3[1]+_CMD[1]*ARM_VERT]; // 主臂顶端
_CTD   = [ARM_DIR*cos(_CTIP), sin(_CTIP)];             // 顶部件方向 (y,z)
_CQ3   = [_CQ0[0]+ARM_TIP_LEN*_CTD[0], _CQ0[1]+ARM_TIP_LEN*_CTD[1]]; // 顶部件末端(臂顶)
// 圆盘中心 = 臂顶正上方(竖直): y 与臂顶相同, z = 臂顶 z + CONN_LIFT
_CONP   = [ _CQ3[0],  _CQ3[1] + CONN_LIFT ];           // 圆盘中心(y,z)

// M5 间隙孔半径
RH = HOLE_D/2;

// 圆形连接件(热熔螺母接口)模块定义 (来自 圆形连接件.scad, 只定义模块, 不渲染)
include <圆形连接件.scad>

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

// ========== 延长臂: 下段横移 + 主直臂(可倾斜) + 顶部件 ==========
// 主直臂方向角 = ARM_MAIN_ANGLE(与水平面夹角, 90=垂直)。下段 Bézier 从底座顶(竖直)平滑过渡到
// 主臂起点, 且末端切向 = 主臂方向(无折角)。顶部件位于主臂顶端, 方向角 = ARM_TIP_ANGLE。
// 截面: 下段从底座(BASE)平滑过渡到臂(ARM); 主臂、顶部件保持臂截面。
// 注意: 本 OpenSCAD 的 cos/sin/atan2 以"度"为单位(cos(90)=0)。
function _ease(u) = (u >= 1) ? 1 : (u <= 0 ? 0 : (1 - cos(180*u))/2);
// 三次 Bézier 点/切线(2D, (y,z) 平面)
function _bez(p0,c1,c2,p3,u) =
    let(v = 1-u, a=v*v*v, b=3*v*v*u, c=3*v*u*u, d=u*u*u)
    [a*p0[0]+b*c1[0]+c*c2[0]+d*p3[0],
     a*p0[1]+b*c1[1]+c*c2[1]+d*p3[1]];
function _bezd(p0,c1,c2,p3,u) =
    let(v = 1-u, a=3*v*v, b=6*v*u, c=3*u*u)
    [a*(c1[0]-p0[0])+b*(c2[0]-c1[0])+c*(p3[0]-c2[0]),
     a*(c1[1]-p0[1])+b*(c2[1]-c1[1])+c*(p3[1]-c2[1])];

module arm() {
    N    = FC;
    main = ARM_MAIN_ANGLE;
    mdir = [ARM_DIR*cos(main), sin(main)];      // 主直臂方向 ((y,z))
    // ---- 1) 下段横移: 底座顶(竖直) -> 主臂起点, 末端切向=主臂方向 ----
    p0 = [0, BASE_H];
    p3 = [ARM_DIR*ARM_OFFSET, BASE_H + ARM_BEND];   // 主臂起点
    h1 = ARM_CURVE * sqrt(pow(ARM_OFFSET,2) + pow(ARM_BEND,2))/2 + 1e-9;
    c1 = [p0[0], p0[1] + h1];                       // 切向竖直
    c2 = [p3[0] - h1*mdir[0], p3[1] - h1*mdir[1]];  // 切向=主臂方向
    for(i=[0:N-1]) {
        u  = (i+0.5)/N;
        pp = _bez(p0, c1, c2, p3, u);
        dd = _bezd(p0, c1, c2, p3, u);
        th = atan2(dd[0], dd[1]);
        e  = _ease(u);
        w  = BASE_W + (ARM_W - BASE_W)*e;
        tt = BASE_T + (ARM_T - BASE_T)*e;
        L  = 2.6 * sqrt(pow(p3[0]-p0[0],2)+pow(p3[1]-p0[1],2)) / N;
        translate([0, pp[0], pp[1]]) rotate([-th,0,0]) cube([w, tt, L], center=true);
    }
    // ---- 2) 主直臂(倾角=ARM_MAIN_ANGLE) ----
    ds  = ARM_VERT/N;
    for(i=[0:N-1]) {
        s  = (i+0.5)*ds;
        yy = p3[0] + mdir[0]*s;
        zz = p3[1] + mdir[1]*s;
        th = atan2(mdir[0], mdir[1]);
        translate([0, yy, zz]) rotate([-th,0,0]) cube([ARM_W, ARM_T, 2.6*ds], center=true);
    }
    // ---- 3) 顶部件(倾角=ARM_TIP_ANGLE): 主臂顶 -> 顶部件末端 ----
    tip = ARM_TIP_ANGLE;
    tdir= [ARM_DIR*cos(tip), sin(tip)];
    q0  = [p3[0] + mdir[0]*ARM_VERT, p3[1] + mdir[1]*ARM_VERT];  // 主臂顶端
    q3  = [q0[0] + ARM_TIP_LEN*tdir[0], q0[1] + ARM_TIP_LEN*tdir[1]];
    h2  = ARM_CURVE * ARM_TIP_LEN/2 + 1e-9;
    d1  = [q0[0] + h2*mdir[0], q0[1] + h2*mdir[1]];        // 切向=主臂方向
    d2  = [q3[0] - h2*tdir[0], q3[1] - h2*tdir[1]];        // 切向=顶部件方向
    dsl = ARM_TIP_LEN/N;
    for(i=[0:N-1]) {
        u  = (i+0.5)/N;
        pp = _bez(q0, d1, d2, q3, u);
        dd = _bezd(q0, d1, d2, q3, u);
        th = atan2(dd[0], dd[1]);
        translate([0, pp[0], pp[1]]) rotate([-th,0,0]) cube([ARM_W, ARM_T, 2.6*dsl], center=true);
    }
}

// ========== 合成 ==========
union() {
    difference() {
        union() {
            base();
            arm();
        }
        holes();
    }

    // ---- 过渡(棱锥磨圆): 大端=臂顶方截面 -> 小端(探到圆盘中心), 小端被半径=圆盘半径(15)的圆柱
    //     磨成凹圆弧, 凹弧面正好贴合圆盘外缘 → 过渡段沿圆盘外圆周趴下, 绝不侵入圆盘工作面。 ----
    TIP_TH = atan2(_CTD[0], _CTD[1]);   // 顶部件端面相对 +Z 的倾角(度)
    difference() {
        hull() {
            // 大端: 臂顶方形截面(与顶部件端面同尺寸同面)
            translate([0, _CQ3[0], _CQ3[1]]) rotate([-TIP_TH,0,0])
                cube([ARM_W, ARM_T, 6], center=true);
            // 小端: 圆盘中心处一个小圆鼻(轴向X, 与圆盘同向), 会被磨圆柱切掉
            translate([CONN_X, _CONP[0], _CONP[1]]) rotate([0,-90,0])
                cylinder(r=4, h=13, center=true);
        }
        // 磨圆柱: 半径=圆盘半径, 轴向X, 圆心=圆盘中心
        translate([CONN_X, _CONP[0], _CONP[1]]) rotate([0,-90,0])
            cylinder(r=CONN_R, h=40, center=true);
    }

    // ---- 圆盘本体 (圆形连接件) ----
    translate([CONN_X, _CONP[0], _CONP[1]])
        rotate([0, -90, 0])
        translate([0, 0, -6.5])   // 圆盘 z=0..13 → 旋转后沿X; 回移 -13/2 使盘心在基点
            circular_connector();
}
