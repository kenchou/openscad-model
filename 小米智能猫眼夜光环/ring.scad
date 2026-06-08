// 小米智能猫眼夜光环
// 内径 60.5mm，环宽 4mm，高 4mm
// 顶面外侧倒角，内侧不倒角，底面不倒角

inner_d = 60.5;        // 内径 (mm)
ring_w  = 4;           // 环宽 (mm)
height  = 4;           // 高度 (mm)
chamfer = 0.8;         // 外侧倒角尺寸 (mm)

inner_r = inner_d / 2; // 内半径
outer_r = inner_r + ring_w; // 外半径

$fn = 120; // 圆滑度

rotate_extrude()
    polygon(points = [
        [inner_r, 0],                // 底部内侧
        [outer_r, 0],                // 底部外侧
        [outer_r, height - chamfer], // 外侧倒角起点
        [outer_r - chamfer, height], // 外侧倒角终点
        [inner_r, height],           // 顶部内侧
    ]);
