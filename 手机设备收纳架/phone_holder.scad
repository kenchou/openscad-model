include <BOSL2/std.scad>
include <BOSL2/math.scad>

// 隔板
module separator(size) {
    cuboid(
        size, rounding=1,
        except=[BOTTOM],
        $fn=24
    );
};

// 分隔间隙
gap=[2, 15, 26, 26, 23, 15, 15];
for (i=[0:6]) {
    //echo(list=select(gap, 0, i));
    //echo(i = i, gap = gap[i], x = 5*i + sum(select(gap, 0, i)));
    // 绘制隔板
    translate([5*i + sum(select(gap, [0:i])),separatorDeep/2,separatorHeight/2+baseHeight/2]) separator([separatorWidth, separatorDeep, separatorHeight]);
}
// 绘制底面
translate([baseWidth/2, baseDeep/2, baseHeight/2]) cuboid([baseWidth, baseDeep, baseHeight], rounding=2, except=[BOTTOM], $fn=64);

// 充电底座
translate([baseHeight/2, baseDeep/2, -rechargerHeight/2]) 
    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=1, except=[TOP], $fn=64);
translate([baseWidth - baseHeight/2, baseDeep/2, -rechargerHeight/2]) 
    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=1, except=[TOP], $fn=64);

// recharger
translate([(baseWidth - rechargerWidth)/2, baseDeep/2, -rechargerHeight/2]) 
    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=1, except=[TOP], $fn=64);
translate([(baseWidth - rechargerWidth)/2 + rechargerWidth, baseDeep/2, -rechargerHeight/2]) 
    cuboid([baseHeight, baseDeep, rechargerHeight], rounding=1, except=[TOP], $fn=64);

baseWidth       = 155;              // 底座长
baseDeep        = 90;               // 底座宽
baseHeight      = 5;                // 底座高
separatorWidth  = 3;                // 隔板厚度
separatorDeep   = baseDeep;         // 隔板宽
separatorHeight = 36-baseHeight/2;  // 隔板高
rechargerHeight = 42;               // 充电器高
rechargerWidth  = 100;              // 充电器宽（由于cuboid是外部宽度，此处实际应设为：充电器实际宽+壁厚baseHeight）