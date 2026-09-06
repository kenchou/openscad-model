include <BOSL2/std.scad>
include <BOSL2/math.scad>

// ===================================================================
//  phone_holder_cuktech_15_desktop — v3「蜂窝网格」版
//  基于 v2「设备列表」版,改动:
//    1) 设备列表改为字符串 `device_spec = "名称:厚度,名称:厚度,..."`:
//       解析出厚度驱动隔板(超宽截断),并把设备名**刻到底板**。
//    2) 所有竖直面板(隔板 + 支脚/recharger)做成**蜂窝网格**(六角孔贯穿板厚、四周留实边),
//       以增加通风散热并节省材料;底板(水平)保持实心。
//  说明:按钮孔腔保留(默认 SHOW_CUTOUT=true);受按钮孔影响的隔板自动缩短前端让出按钮孔(更圆润)。
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

// ---------- 设备列表解析("名称:厚度,名称:厚度,...") ----------
// 每个条目 "名称:厚度",整体用逗号分隔;名称/厚度两侧多余空格会被去掉。
function _spec_entry(e) = let(p = str_split(e, ":")) [str_strip(p[0]," "), parse_num(str_strip(p[1]," "))];
function parse_spec(spec)   = [for (e = str_split(spec, ",", keep_nulls=false)) _spec_entry(e)];
function dev_thick(spec)    = [for (e = parse_spec(spec)) e[1]];   // 厚度列表(驱动隔板)
function dev_names(spec)    = [for (e = parse_spec(spec)) e[0]];   // 设备名列表(刻字)

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
    res   = fit_devices(dev_thick(device_spec), separatorWidth, device_gap, baseWidth);
    kept  = res[0];
    sep_l = len(kept) ? concat(res[1], [res[2] + separatorWidth/2]) : [];

    // 按钮孔前区:受影响的隔板自动缩短前端、末端圆角,让出按钮孔,不被按钮孔切到
    front_cut = button_hole_length + bh_margin;   // 受影响隔板的前缘 y(避开按钮孔;bh_margin 为全局参数)
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

// 字符宽度系数(估算文字沿读向长度):数字/字母≈0.55em,其余(中文/全角)≈1em
function _chw(c) = (c>="0"&&c<="9") || (c>="A"&&c<="Z") || (c>="a"&&c<="z") ? 0.55 : 1.0;

// ---------- 设备名刻到底板 ----------
// 文字沿 Y(前后)方向、居槽中心;若该槽与按钮孔区域重叠(且开孔),文字改用**剩余区域**:
// 起点移到按钮孔后壁之后,并按剩余宽度缩放字号,避免文字被按钮孔挖掉。
// 朝向由 engrave_flip 切换;SHOW_CUTOUT=false 时不做避让,文字用整槽。
module name_labels(spec) {
    thick = dev_thick(spec);
    names = dev_names(spec);
    res   = fit_devices(thick, separatorWidth, device_gap, baseWidth);
    kept  = res[0];
    n     = len(kept);
    if (n > 0) {
        sep_l = concat(res[1], [res[2] + separatorWidth/2]);
        bh_x0 = button_hole_pos[0] - button_hole_width/2;      // 按钮孔 x 区
        bh_x1 = button_hole_pos[0] + button_hole_width/2;
        bh_yback = button_hole_length + bh_margin;             // 按钮孔后界 + 余量(文字起点)
        for (i=[0:n-1]) {
            xc  = (sep_l[i] + sep_l[i+1]) / 2;                 // 该槽中心 x
            sw  = sep_l[i+1] - sep_l[i] - separatorWidth;      // 槽内宽(沿 X)
            s0  = sep_l[i] + separatorWidth/2;                 // 槽材料左缘
            s1  = sep_l[i+1] - separatorWidth/2;               // 槽材料右缘
            ov_w = min(s1, bh_x1) - max(s0, bh_x0);            // 槽与按钮孔的 x 重叠宽
            // 只有孔切成槽宽 ≥ engrave_avoid_frac(默认1/3)时才避让;小重叠直接整槽居中,显示更全
            avoid = SHOW_CUTOUT && (ov_w >= engrave_avoid_frac * sw);
            y0 = avoid ? bh_yback : 0;                         // 文字可用区起点(沿 Y)
            y1 = baseDeep;                                     // 文字可用区终点
            ylen = y1 - y0;
            K  = sum([for (j=[0:len(names[i])-1]) _chw(names[i][j])]);   // 字符宽度系数和
            fsz = min(engrave_font, sw - 2, ylen/K*0.9);       // 字号受默认/槽宽/剩余长度限制
            ymid = (y0 + y1) / 2;
            translate([xc, ymid, baseHeight - engrave_depth])
                rotate([0,0, engrave_flip ? 90 : -90])
                    linear_extrude(height = engrave_depth)
                        text(names[i], size=fsz, halign="center", valign="center", font=engrave_font_face);
        }
    }
}

// ---------- 合成 ----------
difference() {
    complete_holder();
    if (SHOW_CUTOUT) cutout_shape(button_hole_pos);
    name_labels(device_spec);      // 设备名刻到底板
}

// ===================================================================
//  ★ 定制参数(集中在本文件末尾,与源文件风格一致;请在此修改)★
// ===================================================================
// 设备列表:"名称:厚度,名称:厚度,..."(厚度驱动隔板;名称刻到底板)
// 例:紫米10 厚22,小米pad5 厚12,酷态科10号mini 厚12,酷态科10号air 厚34,墨案迷你阅 厚12
device_spec = "紫米10号:22,小米pad:12,酷态科10号air:19,酷态科10号mini:34,手机:12";
device_gap      = 1;        // 槽两侧各预留余量(mm);槽净宽 = 设备厚度 + 2*device_gap

// 刻字参数(刻到底板顶面)
engrave_depth     = 0.6;        // 刻字深度(mm,建议 0.5~1)
engrave_font      = 6;          // 刻字字号(mm;受槽宽限制会自动缩小)
engrave_font_face = "Songti SC";  // 中文字体(宋体,最通用;本机可用 Songti SC / Arial Unicode MS / Hiragino Sans GB)
engrave_flip      = true;        // 刻字朝向:true=反向(文字旋转180°),false=默认朝向
engrave_avoid_frac = 1/3;        // 按钮孔切成槽宽达该比例才避让文字(否则整槽居中,显示更全)

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
bh_margin          = 1.25;             // 按钮孔后壁余量(mm):受影响隔板前缩、刻字避让都用到

// ---------- 诊断(置于参数之后,以便读到参数;渲染时打印) ----------
_devs = dev_thick(device_spec);
_ft   = fit_devices(_devs, separatorWidth, device_gap, baseWidth);
echo(str("设备数=", len(_devs), "  保留=", len(_ft[0]),
         "  内容总宽=", _ft[2] + separatorWidth,
         " / baseWidth=", baseWidth,
         "  超出忽略=", len(_devs) - len(_ft[0]), " 台"));
echo(str("保留设备=", dev_names(device_spec)));
echo(str("保留设备厚度=", _ft[0]));
echo(str("隔板中心x=", [for (xc = (len(_ft[0]) ? concat(_ft[1], [_ft[2] + separatorWidth/2]) : [])) xc]));
