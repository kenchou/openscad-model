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

// 充电器
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

// 整体结构 - 用一个模块包含底板和隔板
module complete_holder() {
    // 分隔间隙
    gap=[1.5, 23, 23, 32, 15, 15];
    for (i=[0:5]) {
        // 绘制隔板
        translate([5*i + sum(select(gap, [0:i])),separatorDeep/2,separatorHeight/2+baseHeight/2]) 
            separator([separatorWidth, separatorDeep, separatorHeight]);
    }
    // 绘制底面
    translate([baseWidth/2, baseDeep/2, baseHeight/2])
        cuboid([baseWidth, baseDeep, baseHeight], rounding=2, except=[BOTTOM], $fn=64);
    
    recharger_cuktech15();
}

module hole_mask() {
    
}

// 定义要减去的组合形状
module cutout_shape() {
    // 首先减去一个带圆角的柱体
    translate([baseWidth-60, 10, baseHeight/2])
        cuboid([20, 21, baseHeight+separatorHeight*2], anchor=CENTER, rounding=2, except=[TOP,BOTTOM], $fn=16);

    // 对Y轴两个角进行45度倒角（前端两个角）
    // Y轴前端左角倒角
    translate([baseWidth-60-10, 10-10.5, baseHeight/2])
        rotate([0, 0, -45])
            cuboid([4, 4, baseHeight+separatorHeight*2], anchor=CENTER);

    // Y轴前端右角倒角
    translate([baseWidth-60+10, 10-10.5, baseHeight/2])
        rotate([0, 0, 45])
            cuboid([4, 4, baseHeight+separatorHeight*2], anchor=CENTER);

    // 对Z轴顶部一个角进行倒角
    translate([baseWidth-60, 20, baseHeight/2+(separatorHeight*2)/2]) {
        rotate([45, 0, 0])
            cube([20, 4, 4], center=true);
    }
}

// 按照您的要求：先减去一个带圆角的柱体（保留内部圆角），然后对Y轴两个角和Z轴一个角进行45度倒角
difference() {
    complete_holder();
    cutout_shape();
}

// 调试：半透明显示减去的形状以便定位问题
for (i = [0:1]) %cutout_shape();

//recharger_cuktech15();

// 定制参数
baseWidth       = 155;              // 底座长
baseDeep        = 70;               // 底座宽
baseHeight      = 5;                // 底座高
separatorWidth  = 3;                // 隔板厚度
separatorDeep   = baseDeep;         // 隔板宽
separatorHeight = 36-baseHeight/2;  // 隔板高
rechargerHeight = 42;               // 充电器高
rechargerWidth  = 75;              // 充电器宽（由于cuboid是外部宽度，此处实际应设为：充电器实际宽+壁厚baseHeight）