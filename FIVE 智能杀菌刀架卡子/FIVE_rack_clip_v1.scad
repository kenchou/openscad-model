include <BOSL2/std.scad>


module clip() 
{
    union() {
        cube([baseWidth, baseDepth, baseHeight]);
        difference() {
            translate([paddingX, paddingY, baseHeight]) {
                cube([clipWidth, clipDepth, clipHeight]);
            }
            translate([baseWidth / 2 - 0.5, -50, baseHeight]) {
                cube([1, 100, 100]);
            }

        }
    }
}


/**
 * @param width 刀鞘口宽度
 * @param wall 刀鞘壁厚度
 */
module open_sheath(width, wall)
{
    //echo(baseDepth=baseDepth, clipHeight=clipHeight);
    rect_tube(
        isize1=[width,clipWidth], isize2=[width,clipWidth], irounding=2, 
        size1=[width+wall, baseDepth], size2=[width+wall+10, baseDepth], rounding=3,
        h=baseHeight
    );
    translate([0,0,baseHeight]) {
        difference() {
            rect_tube(
            isize1=[width+0.1,clipWidth-0.1], isize2=[width+0.1,clipWidth-0.1], irounding=2,
            size1=[width+wall+5, clipWidth], size2=[width+wall, clipWidth], rounding=2,
                h=clipHeight
            );
            cuboid([width-4,baseWidth,clipHeight*2]);
        }
    }
}


//clip();
open_sheath(width=30, wall=2, $fn=64);    // 刀鞘口宽度，刀鞘厚度


baseWidth  = 15;
baseDepth  = baseWidth / 2;
baseHeight = 3;

clipWidth  = 4.5;   // V1
clipWidth  = 4.0;   // V2
clipDepth  = baseDepth;
clipHeight = 20;

paddingX = (baseWidth - clipWidth) / 2;
paddingY = (baseDepth - clipDepth) / 2;

space = 3;