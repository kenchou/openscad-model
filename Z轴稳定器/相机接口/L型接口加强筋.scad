include <BOSL2/std.scad>

module base(){
    difference() {
        cyl(h=base_h, r=base_r, chamfer2=1, anchor=BOTTOM) position(CENTER+BOTTOM) 
            translate([20, 0, 0]) cube([6, 16, base_h], anchor=BOTTOM);
        translate([0,0,-3]) cylinder(h=10, r=3);
    };
//    translate([20, 0, 0]) cube([16, 16, base_h], anchor=BOTTOM);
}

// 圆管(管壁 r=19..20)与方管(壁 |y|=7..8)交汇处加圆角过渡, 减小应力集中。
// 用一段与圆管外表面、方管顶面相切的圆弧把凹角填平滑。
//  r        —— 圆角半径(可见的圆滑过渡面)
//  r_back   —— 向圆管壁内缩的重叠半径(须 19<r_back<20, 与管壁体积重叠保证水密融合)
//  y_back   —— 向方管壁内缩的重叠 y(须 7<y_back<8)
module corner_fillet_fill(r=3, r_back=19.4, y_back=7.4){
    R = 20;                 // 圆管外半径
    yc = 8;                 // 方管外半宽(上/下壁面 y=±8)
    cxp = sqrt((R+r)*(R+r) - (yc+r)*(yc+r));   // 圆角圆心 x
    C = [cxp, yc+r];                           // 圆角圆心
    tline = [cxp, yc];      // 与方管顶面 y=yc 的切点
    tcirc = R/(R+r)*C;      // 与圆管外表面 r=R 的切点
    tcirc_i = tcirc*(r_back/R);                 // 圆管侧向内重叠点
    p_back = [sqrt(r_back*r_back - y_back*y_back), y_back];
    tline_i = [cxp, y_back];                    // 方管侧向内重叠点
    b0 = atan2(tcirc[1]-C[1], tcirc[0]-C[0]);
    b1 = atan2(tline[1]-C[1], tline[0]-C[0]);
    ci = atan2(tcirc_i[1], tcirc_i[0]);
    pi_ang = atan2(p_back[1], p_back[0]);
    linear_extrude(height=interface_h)
        polygon(concat(
            [tline],
            [for(k=[0:24]) let(b=b0+(b1-b0)*k/24) [C[0]+r*cos(b), C[1]+r*sin(b)]],
            [tcirc],[tcirc_i],
            [for(k=[0:24]) let(a=ci+(pi_ang-ci)*k/24) [r_back*cos(a), r_back*sin(a)]],
            [p_back],[tline_i]
        ));
}

// 方管内壁 |y|=7 与圆管内壁 r=19 交接处(17.664,±7)是一个凸出的尖点(凸角)。
// 用与内壁 r=R、内腔顶 y=yc 相切的圆弧把尖点磨掉, 变成圆润的凸点。
//  r   —— 磨圆半径
module inner_convex_cut(r=2){
    R = 19;                 // 圆管内半径
    yc = 7;                 // 方管内半宽(上/下内壁 y=±7)
    cxp = sqrt((R+r)*(R+r) - (yc+r)*(yc+r));   // 圆心 x
    C = [cxp, yc+r];                           // 圆心(材料侧: r>R、y>yc)
    tline = [cxp, yc];      // 与方管内壁 y=yc 切点
    tcirc = R/(R+r)*C;      // 与圆管内壁 r=R 切点
    corner = [sqrt(R*R-yc*yc), yc];            // 角点 (17.664,7)
    a_corner = atan2(yc, sqrt(R*R-yc*yc));
    a_tcirc = atan2(tcirc[1], tcirc[0]);
    b0 = atan2(tcirc[1]-C[1], tcirc[0]-C[0]);
    b1 = atan2(tline[1]-C[1], tline[0]-C[0]);
    linear_extrude(height=interface_h+20) polygon(concat(
        [ corner ],
        [ for(k=[0:28]) let(a=a_corner+(a_tcirc-a_corner)*k/28) [R*cos(a), R*sin(a)] ],  // 沿 r=R 到切点
        [ tcirc ],
        [ for(k=[0:28]) let(b=b0+(b1-b0)*k/28) [C[0]+r*cos(b), C[1]+r*sin(b)] ],        // 圆角弧
        [ tline ]
    ));
}

module rib() {
    union() {
    difference() {
        union() {
            difference() {
                right_half() 
                    tube(h=interface_h, or=20, ir=base_r-1, anchor=BOTTOM) 
                    position(CENTER+BOTTOM) 
                    translate([20, 0, 0])
                        rect_tube(h=interface_h, size=[6+2, 16], wall=1, anchor=BOTTOM);
                cyl(h=interface_h, r=base_r-1, anchor=BOTTOM) position(CENTER+BOTTOM) translate([20, 0, 0]) cube([6,14,interface_h+10], anchor=BOTTOM);
            };
            // 方管/圆管交界处外侧凹角填料圆角(上、下各一处)
            corner_fillet_fill(r=FILL_R);
            mirror([0,1,0]) corner_fillet_fill(r=FILL_R);
        }
        // 方管内壁与圆管内壁交接凸角: 磨掉尖点(上、下两处)
        #translate([-0.1,0,0]) inner_convex_cut(r=INNER_R);
        #translate([-0.1,0,0]) mirror([0,1,0]) inner_convex_cut(r=INNER_R);
        translate([-5,0,0]) ycyl(h=50, r=30, anchor=BOTTOM);
    };
    translate([23,0,4]) fillet(l=16, r=5.35, ang=90, spin=180, orient=BACK);
    }
}

//base();
rib();
//rect_tube(h=interface_h, size=[16, 16], wall=1, anchor=BOTTOM);


$fn=64;
base_h=4;
base_r=20;
interface_h=30;
FILL_R=3;         // 方管/圆管交界处外侧凹角填料圆角半径
INNER_R=2;        // 方管内壁与圆管内壁交接凸角磨圆半径(把凸出尖点磨掉)
