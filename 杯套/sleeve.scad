include <BOSL2/std.scad>

tube(id=inner_diameter, od=inner_diameter+wall_thickness*2, h=height, chamfer=chamfer_size);

// 参数定义
inner_diameter = 72;     // 内径
wall_thickness = 2.5;    // 壁厚
height = 30;             // 高度
chamfer_size = 0.8;      // 倒角大小
