include <BOSL2/std.scad>


rect_tube(isize=inner_size, wall=wall_thickness, h=height, irounding=rounding_size, rounding=rounding_size+wall_thickness);


// 参数定义
inner_size=[10,16];
wall_thickness = 2;    // 壁厚
height = 20;             // 高度
rounding_size = 3;      // 底部圆角大小

outer_size = inner_size + [2*wall_thickness, 2*wall_thickness];

//inner_size_3d=concat(inner_size,[height+10]);
//outer_size_3d=concat(outer_size,[height]);

//echo("inner_size_3d=", inner_size_3d);
//echo("outer_size_3d=", outer_size_3d);
