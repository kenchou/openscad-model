include <BOSL2/std.scad>
include <BOSL2/math.scad>

// ===================================================================
//  phone_holder_cuktech_15_desktop — v3「蜂窝网格」版
//  基于 v2「设备列表」版,改动:
//    1) 保持 v2 的「设备厚度列表 devices」驱动隔板的做法(超宽截断、参数在文件末尾)。
//    2) 把**所有竖直面板**(隔板 + 支脚/recharger)做成**蜂窝网格**:
//       在面板的 Y-Z 平面打六角孔、沿面板厚度(X)贯穿,四周留实边(mesh_border),
//       以增加通风散热并节省材料。底板(水平)保持实心。
//  说明:按钮孔腔保留(默认 SHOW_CUTOUT=true);支脚、隔板保持原外形(圆角)仅内部蜂窝化。
// ===================================================================

// ---------- 蜂窝挖孔 ----------
// 在给定面板的本地坐标系(Y-Z 平面)生成六角孔实体,沿 X 贯穿 t 厚。
// cell=六角孔外接圆半径(mm), wall=孔间壁厚(mm), border=四周实边宽(mm)。
module honeycomb_cut(t, sy, sz, cell, wall, border) {
    Rt = cell + wall/sqrt(3);     // 晶格半径,使孔间壁厚恰为 wall
    dx = 1.5*Rt;                  // 列距(Y 向,前后) —— 六角尖头朝前后(Y)
    dz = sqrt(3)*Rt;              // 行距(Z 向,上下)
    nu = ceil(sy/dx/2) + 1;       // 六角柱覆盖整个面板,再由窗口裁剪出平滑边界
    nv = ceil(sz/dz/2) + 1;
    intersection() {
        union() {
            for (i=[-nu:nu])
                for (j=[-nv:nv])
                    let(u = i*dx, v = j*dz + (i%2 ? dz/2 : 0))
                        translate([0, u, v])
                            rotate([90,0,0]) rotate([0,90,0])
                                cylinder(r=cell, h=t+2, center=true, $fn=6);
        }
        // 窗口:四周留 border 实边,直线边界 → 蜂窝区域边缘平滑、与隔板外形一致
        cuboid([t+2, sy-2*border, sz-2*border], rounding=0);
    }
}

// ---------- 设备列表派生 ----------
function slot_width(d) = d + 2*device_gap;

// 递归遍历设备列表(同 v2):放不下则连同后续一起忽略。返回 [保留设备, 各槽左隔板中心x, 内容总宽]。
function fit_devices(devs, sep, gap, baseW, i=0, x=0, kept=[], walls=[]) =
    i >= len(devs) ? [kept, walls, x]
  : let(
        sw    = slot_width(devs[i]),
        nextx = x + sep + sw,
        fits  = nextx + sep <= baseW
    )
    fits ? fit_devices(devs, sep, gap, baseW, i+1, nextx,
                       concat(kept, [devs[i]]),
                       concat(walls, [x + sep/2]))
        : [kept, walls, x];

// ---------- 隔板(蜂窝化) ----------
module separator(size) {
    t = size[0]; sy = size[1]; sz = size[2];
    difference() {
        cuboid([t, sy, sz], rounding=1, except=[BOTTOM], $fn=24);
        honeycomb_cut(t, sy, sz, mesh_cell, mesh_wall, mesh_border);
    }
}

// ---------- 支脚/充电器(原外形,蜂窝化;保持原几何位置由调用处决定) ----------
module recharger_cuktech15() {
    difference() {
        cuboid([baseHeight, baseDeep, rechargerHeight], rounding=2, except=[TOP], $fn=64);
        honeycomb_cut(baseHeight, baseDeep, rechargerHeight, mesh_cell, mesh_wall, mesh_border);
    }
}

// ---------- 主体 ----------
module complete_holder() {
    res   = fit_devices(devices, separatorWidth, device_gap, baseWidth);
    kept  = res[0];
    sep_l = len(kept) ? concat(res[1], [res[2] + separatorWidth/2]) : [];

    // 按钮孔前区:受影响的隔板自动缩短前端、末端圆角,让出按钮孔,不被按钮孔切到
    bh_margin = 3;                                // 前缘离按钮孔后壁的余量
    front_cut = button_hole_length + bh_margin;   // 受影响隔板的前缘 y(避开按钮孔)
    bh_x0 = button_hole_pos[0] - button_hole_width/2;
    bh_x1 = button_hole_pos[0] + button_hole_width/2;

    // 隔板(蜂窝;与按钮孔 x 重叠者自动缩短,让出按钮孔,更圆润)
    for (xc = sep_l) {
        x0 = xc - separatorWidth/2;
        x1 = xc + separatorWidth/2;
        overlap = (x0 < bh_x1) && (x1 > bh_x0);
        if (overlap) {
            sy2 = baseDeep - front_cut;                    // 缩短后的长度
            translate([xc, front_cut + sy2/2, separatorHeight/2 + baseHeight/2])
                separator([separatorWidth, sy2, separatorHeight]);
        } else {
            translate([xc, baseDeep/2, separatorHeight/2 + baseHeight/2])
                separator([separatorWidth, baseDeep, separatorHeight]);
        }
    }

    // 底板(水平,实心)
    translate([baseWidth/2, baseDeep/2, baseHeight/2])
        cuboid([baseWidth, baseDeep, baseHeight], rounding=2, except=[BOTTOM], $fn=64);

    // 支脚/充电器(蜂窝)
    translate([baseHeight/2, baseDeep/2, -rechargerHeight/2])
        recharger_cuktech15();
}

// ---------- 可选:原按钮孔腔 ----------
module cutout_shape(pos) {
    x = pos[0]; y = pos[1]; z = pos[2];
    translate([x, y, z])
        cuboid([button_hole_width, button_hole_length, baseHeight+separatorHeight*2],
               anchor=CENTER, rounding=2, except=[TOP,BOTTOM], $fn=16);
    translate([x-button_hole_width/2, y-button_hole_length/2, z])
        rotate([0, 0, -45]) cuboid([4, 4, baseHeight+separatorHeight*2], anchor=CENTER);
    translate([x+button_hole_width/2, y-button_hole_length/2, z])
        rotate([0, 0, 45])  cuboid([4, 4, baseHeight+separatorHeight*2], anchor=CENTER);
    translate([x, 20, z+(separatorHeight*2)/2])
        rotate([45, 0, 0]) cube([20, 4, 4], center=true);
}

// ---------- 合成 ----------
difference() {
    complete_holder();
    if (SHOW_CUTOUT) cutout_shape(button_hole_pos);
}

// ===================================================================
//  ★ 定制参数(集中在本文件末尾,与源文件风格一致;请在此修改)★
// ===================================================================
// 设备厚度列表(mm)
devices = [9, 16, 20, 12, 15, 11, 18, 13, 10, 14];
device_gap      = 1;        // 槽两侧各预留余量(mm);槽净宽 = 设备厚度 + 2*device_gap

separatorWidth  = 3;        // 隔板厚(mm)
separatorHeight = 33.5;     // 隔板高(不含底板;总高 = baseHeight + separatorHeight)
baseHeight      = 5;        // 底板厚(mm)
baseDeep        = 70;       // 底板宽度/深度(Y 向,mm)
baseWidth       = 155;      // 支架总长(X 向)上限(mm);隔板排布超宽则忽略超出的槽
rechargerHeight = 65;       // 支脚高(mm,保持原值勿改)
rechargerWidth  = 75;       // 预留(原版定义,暂未用)

// 蜂窝网格参数(应用于所有竖直面板:隔板 + 支脚;底板实心)
mesh_cell   = 3.5;          // 六角孔外接圆半径(mm);越小孔越密
mesh_wall   = 1.2;          // 孔间壁厚(mm);≥1 保证可打印
mesh_border = 3;            // 四周实边宽(mm),保证面板与底板/边沿连接

// 按钮孔腔
SHOW_CUTOUT        = true;             // 是否保留原按钮孔腔(默认保留;改为 false 可关闭)
button_hole_width  = 20;
button_hole_length = 21;
button_hole_pos    = [baseWidth - 46, button_hole_length/2, baseHeight/2];

// ---------- 诊断(置于参数之后,以便读到参数;渲染时打印) ----------
_ft = fit_devices(devices, separatorWidth, device_gap, baseWidth);
echo(str("devices=(", len(devices), ")  保留=", len(_ft[0]),
         "  内容总宽=", _ft[2] + separatorWidth,
         " / baseWidth=", baseWidth,
         "  超出忽略=", len(devices) - len(_ft[0]), " 台"));
echo(str("保留设备厚度=", _ft[0]));
echo(str("隔板中心x=", [for (xc = (len(_ft[0]) ? concat(_ft[1], [_ft[2] + separatorWidth/2]) : [])) xc]));
