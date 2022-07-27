include <openscad-tray/tray.scad>

/*
tray(
    [160,170,20], thickness=2, 
    n_columns=4, columns=[0.2, .48, .76],
    n_rows=[1, 1, 2, 1], rows=[false, false, [.1], [.1]],
    bottom_bevel_radius=4, top_bevel_radius=4, 
    dividers_bottom_bevel_radius=4, dividers_top_bevel_radius=4
);
*/

tray(
    [160,170,20], thickness=2, bottom_thickness=1,
    rows_first=true,
    n_rows=2, rows=[.1],
    n_columns=[1, 4], columns=[false, [.24, .52, .80]],
    bottom_bevel_radius=4, top_bevel_radius=4, 
    dividers_bottom_bevel_radius=4, dividers_top_bevel_radius=4
);
