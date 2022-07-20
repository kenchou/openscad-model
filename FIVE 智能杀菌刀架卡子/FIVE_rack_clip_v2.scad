include <BOSL2/std.scad>


/**
 * @param openWidth 开口长
 */
module open_sheath(openWidth)
{
    rect_tube(
        isize1=[openWidth,openDeep], 
        isize2=[openWidth,openDeep], 
        irounding=2, 
        size1=[openWidth+wall, baseDepth], 
        size2=[openWidth+wall+baseHeight*2, baseDepth], 
        rounding=2,
        h=baseHeight
    );
    translate([0,0,baseHeight]) {
        difference() {
            rect_tube(
                isize1=[openWidth,openDeep],    // 开口尺寸 
                isize2=[openWidth,openDeep], 
                irounding=2,
                size1=[openWidth+wall+baseHeight, openDeepMax], 
                size2=[openWidth+wall, openDeepMax], 
                rounding=2,
                h=sheathLength
            );
            // 削去开口宽度，以便可以插入长槽
            rect_tube(
                isize1=[openWidth+wall+baseHeight,openDeep], 
                isize2=[openWidth+wall,openDeep], 
                irounding=2,
                h=sheathLength, 
                wall=wall
            );
        }
    }
}


baseWidth  = 15;
baseDepth  = baseWidth / 2;
baseHeight = 3;

openDeepMax=4.5;    // Five 刀架的刀槽最大宽度。
openDeep=4;         // 刀鞘开口宽度。
wall=2;             // 刀鞘壁厚度。
sheathLength = 20;  // 刀鞘长度。


// L: 28
// M: 22
// S: 18
openWidth=22;   // 命令行方式可以通过 -D openWidth=x 覆盖变量值来调整开口宽度
open_sheath(openWidth, $fn=32);    // 刀鞘口宽度，

echo(openWidth=openWidth);
