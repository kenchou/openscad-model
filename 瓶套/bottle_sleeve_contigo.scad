include <BOSL2/std.scad>

tube(id=inner_diameter, od=inner_diameter+wall_thickness*2, h=height, orounding=rounding_size);

// 参数定义
$fn=256;
inner_diameter = 72;     // 内径
wall_thickness = 2.5;    // 壁厚
height = 30;             // 高度
rounding_size = 2.6;      // 倒角大小
