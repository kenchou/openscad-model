include <BOSL2/std.scad>
include <BOSL2/math.scad>

    
module separator(size) {
    cuboid(
        size, rounding=1,
        except=[BOTTOM],
        $fn=24
    );
};

gap=[26, 25, 22, 15, 15, 15];
for (i=[0:5]) {
    echo(list=select(gap, 0, i));
    echo(i = i, gap = gap[i], x = 5*i + sum(select(gap, 0, i)));
    translate([5*i + sum(select(gap, [0:i])),separatorDeep/2,separatorHeight/2+baseHeight/2]) separator([separatorWidth, separatorDeep, separatorHeight]);
}

translate([baseWidth/2, baseDeep/2, baseHeight/2]) cuboid([baseWidth, baseDeep, baseHeight], rounding=2, $fn=64);

baseWidth       = 150;
baseDeep        = 90;
baseHeight      = 5;
separatorWidth  = 3;
separatorDeep   = baseDeep;
separatorHeight = 32-baseHeight/2;
