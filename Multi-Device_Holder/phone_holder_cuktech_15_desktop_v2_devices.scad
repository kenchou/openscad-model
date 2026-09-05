include <BOSL2/std.scad>
include <BOSL2/math.scad>

// ===================================================================
//  phone_holder_cuktech_15_desktop — v2「设备列表」版
//  相对原版(phone_holder_cuktech_15_desktop.scad)的改动:
//    1) 原来的 gap 数组(隔板间空隙)改为「设备厚度列表 devices」:
//       每个元素 = 该槽位要放设备的厚度(mm),如手机厚 9mm、充电宝厚 16mm。
//       槽净宽 = 设备厚度 + 2*device_gap(两侧各留余量)。
//    2) 迭代 devices 生成隔板;每个槽由「左隔板 + 槽 + 右隔板」围成。
//    3) 若迭代累计宽度超过指定支架宽度 baseWidth,超出的设备直接忽略(不渲染)。
//  说明:下端「支脚/充电器」部分(垂在底板下的 65mm 块)保持原样,完全未改动。
//  风格说明:定制参数集中在本文件末尾,与源文件一致;请在此处修改。
// ===================================================================

// ---------- 派生 ----------
// 单个槽净宽 = 设备厚度 + 两侧余量
function slot_width(d) = d + 2*device_gap;

// 递归遍历设备列表:x = 当前(下一个)隔板的左边缘。
// 一个设备要能放进去,要求「左隔板 + 槽 + 右隔板」都在 baseWidth 内;放不下则连同
// 后续设备一起忽略。返回 [保留的设备厚度列表, 各槽左隔板中心x, 内容总宽(末隔板右缘)]。
function fit_devices(devs, sep, gap, baseW, i=0, x=0, kept=[], walls=[]) =
    i >= len(devs) ? [kept, walls, x]
  : let(
        sw    = slot_width(devs[i]),
        nextx = x + sep + sw,          // 该设备右隔板的左边缘
        fits  = nextx + sep <= baseW   // 需连右侧隔板一起装下才保留
    )
    fits ? fit_devices(devs, sep, gap, baseW, i+1, nextx,
                       concat(kept, [devs[i]]),
                       concat(walls, [x + sep/2]))     // 记录该槽左隔板中心
        : [kept, walls, x];

// ---------- 隔板 ----------
module separator(size) {
    cuboid(size, rounding=1, except=[BOTTOM], $fn=24);
}

// ---------- 支脚/充电器(保持原样,未改动) ----------
module recharger_cuktech15() {
    // 底座
    translate([baseHeight/2, baseDeep/2, -rechargerHeight/2])
        cuboid([baseHeight, baseDeep, rechargerHeight], rounding=2, except=[TOP], $fn=64);
    //translate([baseWidth - baseHeight/2, baseDeep/2, -rechargerHeight/2])
    //    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=2, except=[TOP], $fn=64);
    // recharger
    //translate([(baseWidth - rechargerWidth)/2, baseDeep/2, -rechargerHeight/2])
    //    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=1, except=[TOP], $fn=64);
    //translate([(baseWidth - rechargerWidth)/2 + rechargerWidth, baseDeep/2, -rechargerHeight/2])
    //    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=1, except=[TOP], $fn=64);
    // 背面挡板
    // translate([baseWidth/2, baseDeep - baseHeight/2, -rechargerHeight/2])
    //     cuboid([baseWidth, baseHeight, rechargerHeight], rounding=2, except=[TOP], $fn=64);
}

// ---------- 主体 ----------
module complete_holder() {
    res   = fit_devices(devices, separatorWidth, device_gap, baseWidth);
    kept  = res[0];
    // 每个保留槽的「左隔板」+ 末尾一个「右隔板」
    sep_l = len(kept) ? concat(res[1], [res[2] + separatorWidth/2]) : [];

    // 隔板
    for (xc = sep_l)
        translate([xc, baseDeep/2, separatorHeight/2 + baseHeight/2])
            separator([separatorWidth, baseDeep, separatorHeight]);

    // 底板
    translate([baseWidth/2, baseDeep/2, baseHeight/2])
        cuboid([baseWidth, baseDeep, baseHeight], rounding=2, except=[BOTTOM], $fn=64);

    // 支脚/充电器(保持原样)
    recharger_cuktech15();
}

// ---------- 可选:原按钮孔腔(默认关闭,确认隔板布局后再决定) ----------
module cutout_shape(pos) {
    x = pos[0]; y = pos[1]; z = pos[2];
    // 带圆角柱体
    translate([x, y, z])
        cuboid([button_hole_width, button_hole_length, baseHeight+separatorHeight*2],
               anchor=CENTER, rounding=2, except=[TOP,BOTTOM], $fn=16);
    // Y 前端左/右角 45° 倒角
    translate([x-button_hole_width/2, y-button_hole_length/2, z])
        rotate([0, 0, -45]) cuboid([4, 4, baseHeight+separatorHeight*2], anchor=CENTER);
    translate([x+button_hole_width/2, y-button_hole_length/2, z])
        rotate([0, 0, 45])  cuboid([4, 4, baseHeight+separatorHeight*2], anchor=CENTER);
    // Z 顶部一角倒角
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
devices = [9, 16, 20, 12, 15, 11, 18, 13, 10, 14];   // 设备厚度列表(mm):手机厚、充电宝厚... 按顺序从左往右摆放
device_gap      = 1;        // 槽两侧各预留余量(mm);槽净宽 = 设备厚度 + 2*device_gap

separatorWidth  = 3;        // 隔板厚(mm)
separatorHeight = 33.5;     // 隔板高(不含底板;总高 = baseHeight + separatorHeight)
baseHeight      = 5;        // 底板厚(mm)
baseDeep        = 70;       // 底板宽度/深度(Y 向,mm)
baseWidth       = 155;      // 支架总长(X 向)上限(mm);隔板排布超宽则忽略超出的槽
rechargerHeight = 65;       // 支脚高(mm,保持原值勿改)
rechargerWidth  = 75;       // 预留(原版定义,暂未用)

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
