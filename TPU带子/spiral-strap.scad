// Parameters
spiral_width = 1.2;           // Strap thickness in mm
spiral_radius = 85;           // Max radius to fit within 170x170mm
turns = 20;                   // Number of loops
segments_per_turn = 100;      // Smoothness
layer_height = 20;           // Extrusion height

module spiral_strip() {
    for (i = [0 : turns * segments_per_turn - 1]) {
        angle1 = i * 360 / segments_per_turn;
        angle2 = (i + 1) * 360 / segments_per_turn;

        r1 = spiral_radius * i / (turns * segments_per_turn);
        r2 = spiral_radius * (i + 1) / (turns * segments_per_turn);

        x1 = r1 * cos(angle1);
        y1 = r1 * sin(angle1);
        x2 = r2 * cos(angle2);
        y2 = r2 * sin(angle2);

        // Create a ribbon segment between two points
        hull() {
            translate([x1, y1]) circle(d = spiral_width, $fn = 12);
            translate([x2, y2]) circle(d = spiral_width, $fn = 12);
        }
    }
}

// Render the spiral strap
linear_extrude(height = layer_height)
    spiral_strip();
    