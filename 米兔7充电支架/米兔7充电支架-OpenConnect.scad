// 支架 + openconnect plate（整体旋转对齐）
union() {
    rotate([0, 0, 0])
        difference() {
            import("米兔充电支架-支架-r.stl");
            translate([-20, -20, 0]) cube([100, 100, 10]);
        }
    // plate 整体旋转：槽小头朝左(X-)对齐支架小头，槽面朝下
    translate([53, 28, 10])
        rotate([180, 0, -90])
            import("opengrid-plate.stl");
}
