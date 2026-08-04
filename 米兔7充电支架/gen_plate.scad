// 用 openconnect_plate.scad 参数生成 1×2 格 plate
plate_size_unit = "mm";
plate_horizontal_size = 28;
plate_vertical_size = 56;
plate_extra_thickness = 5;
plate_corner_rounding = "None";
plate_corner_rounding_size = 0;
slot_type = "slot";
vase_linewidth = 0.6;
slot_lock_distribution = "Corners";
slot_entryramp_flip = false;
slot_position = "All";
plate_slot_horizontal_alignment = "Center";
plate_slot_vertical_alignment = "Center";
plate_slot_horizontal_offset = 0;
plate_slot_vertical_offset = 0;
slot_side_clearance = 0.1;
slot_depth_clearance = 0.1;
slot_edge_feature_widen = "Both";
slot_edge_bridge_min_width = 0.8;
slot_edge_wall_min_width = 0.6;

include </Users/ken/workspaces/MyWorkspace/opengrid-projects/openconnect_plate.scad>
