include <BOSL2/std.scad>


// 瓶身保护
difference() {
    // 原始形状
    rect_tube(isize=inner_size, wall=wall_thickness, h=height, irounding=rounding_size, rounding=rounding_size+wall_thickness);
    
    // 顶部外侧倒角（锥形切割工具，内侧贴合管子外壁并内收）
    #translate([0, 0, height - top_chamfer])
        rect_tube(
            size1 = outer_size + [6, 6],                             // 外壁底部比管子大 3mm/边
            size2 = outer_size - [2*top_chamfer, 2*top_chamfer] + [6, 6], // 外壁顶部同样大 3mm/边
            isize1 = outer_size,                                      // 内壁底部与管子外壁对齐
            isize2 = outer_size - [2*top_chamfer, 2*top_chamfer],     // 内壁顶部内收 1mm/边（45°）
            h = top_chamfer + 0.01,
            rounding1 = rounding_size + wall_thickness + 6,           // 外壁圆角比管子大
            rounding2 = rounding_size + wall_thickness + 6,
            irounding = rounding_size + wall_thickness,               // 内壁圆角与管子外角一致 R6
            anchor = BOTTOM
        );
}

// 底部保护
rect_tube(size=inner_size, wall=10, h=1, irounding=rounding_size, rounding=rounding_size);

// 参数定义
inner_size=[56,56];
wall_thickness = 2;    // 壁厚
height = 15;             // 高度
rounding_size = 6;      // 底部圆角大小
top_chamfer = 1;        // 上部外侧倒角大小

outer_size = inner_size + [2*wall_thickness, 2*wall_thickness];

inner_size_3d=concat(inner_size,[height+10]);
outer_size_3d=concat(outer_size,[height]);

echo("inner_size_3d=", inner_size_3d);
echo("outer_size_3d=", outer_size_3d);
