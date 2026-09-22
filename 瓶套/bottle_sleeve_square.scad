include <BOSL2/std.scad>


// 瓶身保护
difference() {
    // 外形: 圆角矩形柱, 顶部外缘圆角(沿外轮廓全周等半径滚圆过渡, 直边与四角一致)
    offset_sweep(
        rect(outer_size, rounding = R + wall_thickness),
        height = height,
        top = os_circle(r = top_fillet),
        steps = 16
    );

    // 内腔: 竖直贯通, 顶面保持直角
    translate([0, 0, -0.5])
        linear_extrude(height + 1, convexity = 10)
            polygon(rect(inner_size, rounding = R));
}

// 底部保护
rect_tube(size=inner_size, wall=13, h=4, irounding=R, rounding=R);

// 参数定义
R                = 9;      // 底部圆角大小
inner_size      =[58,58];
height           = 16;             // 高度
wall_thickness = 2;    // 壁厚
top_fillet        = 1.8;        // 顶部外缘圆角半径(需 < 壁厚, 才留出平顶)

outer_size = inner_size + [2*wall_thickness, 2*wall_thickness];

inner_size_3d=concat(inner_size,[height+10]);
outer_size_3d=concat(outer_size,[height]);

echo("inner_size_3d=", inner_size_3d);
echo("outer_size_3d=", outer_size_3d);
