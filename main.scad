include <util.scad>

hole_footprint = 13.98;
plate_thickness = 4;

frame_size = 17;
horizontal_key_spacing = 4;
vertical_key_spacing = 5;
e = .1;
frame_outline_width = 3;

switch_notch_height = 1.4;
switch_notch_width = 6;
switch_notch_depth = 1;

columnStart = -2; // Home row pinkie
columns = 5;

extraPinkies = true;
rowsPerColumn = [4, extraPinkies ? 5 : 4, extraPinkies ? 5 : 4, 4, 4, 3];
yoffsets = [17, 5, 1, 5, 5, 15];
zoffsets = [-4, 0, 4, 0, 0, 0];

keycap_bottom = 18.3;
keycap_top = 12.3;
keycap_height = 9;
keycap_offset = 6.5;

tent_deg = 35;
show_keycaps = false;

col_degrees = 5;
row_degrees = 17;

function getKeyOffset(x, y) =
    let(
        y_offset = -yoffsets[x + 2],
        z_offset = -zoffsets[x + 2],
        offs1 =let(offs = chainRotationOffset(x, frame_size + horizontal_key_spacing, col_degrees))[offs.x, 0, offs.y],
        offs2 = let(offs = chainRotationOffset(y, frame_size + vertical_key_spacing, row_degrees))[0, offs.x, offs.y],
        base_offset = rotate_y(offs2, -x * col_degrees) + offs1 + [0, -yoffsets[x + 2], -zoffsets[x + 2]],
        final_offset = rotate_y(base_offset, -tent_deg)  // Apply final Y-axis rotation
    )
    final_offset;


function getKeyRotation(x, y) = 
        [
            y * row_degrees, 
            -x * col_degrees -tent_deg, 
            0
        ];

module applyKeyOffset(x, y) {
    // Get the offset and rotation values
    koffset = getKeyOffset(x, y);
    rotation = getKeyRotation(x, y);
    
    // Apply the translation and rotations
    translate(koffset)

    rotate(rotation)
    children();
}

fOffset = frame_size / 2;
fOffsetEdge = fOffset + frame_outline_width;
rounding = 5;
fOffsetRoundedEdge = fOffsetEdge - rounding / 2;

module key (l, r, t, b) {
    difference(){
        color(preview_colors ? plate_color : "pink")
        hull() {
            if (l && b) {
                $fn = 4;
                translate([
                    -fOffsetRoundedEdge,
                    -fOffsetRoundedEdge,
                    0,
                ])
                cylinder(plate_thickness, d = rounding, center = true);
            } else {
                translate([
                    - (l ? fOffsetEdge : fOffset),
                    - (b ? fOffsetEdge : fOffset),
                    0,
                ])
                cube([e, e, plate_thickness], center = true);
            }

            if (r && b) {
                $fn = 4;
                translate([
                    fOffsetRoundedEdge,
                    -fOffsetRoundedEdge,
                    0,
                ])
                cylinder(plate_thickness, d = rounding, center = true);
            } else {
                translate([
                    (r ? fOffsetEdge : fOffset),
                    - (b ? fOffsetEdge : fOffset),
                    0,
                ])
                cube([e, e, plate_thickness], center = true);
            }

            if (r && t) {
                $fn = 4;
                translate([
                    fOffsetRoundedEdge,
                    fOffsetRoundedEdge,
                    0,
                ])
                cylinder(plate_thickness, d = rounding, center = true);
            } else {
                translate([
                    (r ? fOffsetEdge : fOffset),
                    (t ? fOffsetEdge : fOffset),
                    0,
                ])
                cube([e, e, plate_thickness], center = true);
            }

            if (l && t) {
                $fn = 4;
                translate([
                    -fOffsetRoundedEdge,
                    fOffsetRoundedEdge,
                    0,
                ])
                cylinder(plate_thickness, d = rounding, center = true);
            } else {
                translate([
                    - (l ? fOffsetEdge : fOffset),
                    (t ? fOffsetEdge : fOffset),
                    0,
                ])
                cube([e, e, plate_thickness], center = true);
            }
        }

        cube([hole_footprint, hole_footprint, plate_thickness + e], center = true);

        // notches
        color(preview_colors ? plate_color : "red")
        translate([0, hole_footprint / 2 + switch_notch_depth / 2, -plate_thickness / 2 + (plate_thickness - switch_notch_height) / 2])
        cube([switch_notch_width + e, switch_notch_depth + e, plate_thickness - switch_notch_height + e], center = true);

        color(preview_colors ? plate_color : "red")
        translate([0, -hole_footprint / 2 - switch_notch_depth / 2, -plate_thickness / 2 + (plate_thickness - switch_notch_height) / 2])
        cube([switch_notch_width + e, switch_notch_depth + e, plate_thickness - switch_notch_height + e], center = true);
    }

    if (show_keycaps) {
        translate([0, 0, keycap_offset])
        color("white")
        hull() {
            cube([keycap_bottom, keycap_bottom, e], center = true);
            translate([0, 0, keycap_height])
            cube([keycap_top, keycap_top, e], center = true);
        }
    }
}

function getMinY(x) = 3 - rowsPerColumn[x + 2];
function getMaxY(x) = 2;
function getMinX() = columnStart;
function getMaxX() = columnStart + columns - 1;

function isTop(x, y) = y == getMaxY(x);
function isBottom(x, y) = y == getMinY(x);
function isLeft(x, y) = x == getMinX();
function isRight(x, y) = x == getMaxX();

function hasKey(x, y) = x >= getMinX() && x <= getMaxX() && y >= getMinY(x) && y <= getMaxY(x);

module frameLeftFace (x, y) {
    rowHeight = frame_size + (isTop(x, y) || isBottom(x, y) ? frame_outline_width : 0);

    applyKeyOffset(x, y)
    translate([
        0,
        0 - (isBottom(x, y) ? (frame_outline_width / 2) : 0) + (isTop(x, y) ? (frame_outline_width / 2) : 0),
        0,
    ])
    translate([-fOffset, 0, 0])
    cube([e, rowHeight, plate_thickness], center = true);
}

module frameRightFace (x, y) {
    rowHeight = frame_size + (isTop(x, y) || isBottom(x, y) ? frame_outline_width : 0);

    applyKeyOffset(x, y)
    translate([
        0,
        0 - (isBottom(x, y) ? (frame_outline_width / 2) : 0) + (isTop(x, y) ? (frame_outline_width / 2) : 0),
        0,
    ])
    translate([fOffset, 0, 0])
    cube([e, rowHeight, plate_thickness], center = true);
}

module frameFrontFace (x, y) {
    colWidth = frame_size + (isLeft(x, y) || isRight(x, y) ? frame_outline_width : 0);

    applyKeyOffset(x, y)
    translate([
        0 - (isLeft(x, y) ? (frame_outline_width / 2) : 0) + (isRight(x, y) ? (frame_outline_width / 2) : 0),
        0,
        0,
    ])
    translate([0, fOffset, 0]) cube([colWidth, e, plate_thickness], center = true);
}

module frameBackFace (x, y) {
    colWidth = frame_size + (isLeft(x, y) || isRight(x, y) ? frame_outline_width : 0);

    applyKeyOffset(x, y)
    translate([
        0 - (isLeft(x, y) ? (frame_outline_width / 2) : 0) + (isRight(x, y) ? (frame_outline_width / 2) : 0),
        0,
        0,
    ])
    translate([0, - (isBottom(x, y) ? fOffsetEdge : fOffset), 0]) cube([colWidth, e, plate_thickness], center = true);
}

module frameFrontRightCorner (x, y) {
    applyKeyOffset(x, y)
    translate([
        (isRight(x, y) ? fOffsetEdge : fOffset),
        (isTop(x, y) ? fOffsetEdge : fOffset),
        0,
    ])
    cube([e, e, plate_thickness], center = true);
}

module frameFrontLeftCorner (x, y) {
    applyKeyOffset(x, y)
    translate([
        - (isLeft(x, y) ? fOffsetEdge : fOffset),
        (isTop(x, y) ? fOffsetEdge : fOffset),
        0,
    ])
    cube([e, e, plate_thickness], center = true);
}

module frameBackRightCorner (x, y) {
    applyKeyOffset(x, y)
    translate([
        +(isRight(x, y) ? fOffsetEdge : fOffset),
        - (isBottom(x, y) ? fOffsetEdge : fOffset),
        0,
    ])
    cube([e, e, plate_thickness], center = true);
}

module frameBackLeftCorner (x, y) {
    applyKeyOffset(x, y)
    translate([
        - (isLeft(x, y) ? fOffsetEdge : fOffset),
        - (isBottom(x, y) ? fOffsetEdge : fOffset),
        0,
    ])
    cube([e, e, plate_thickness], center = true);
}

module top() {
    minX = getMinX();
    maxX = getMaxX();
    for (x = [minX: maxX]) {
        minY = getMinY(x);
        maxY = getMaxY(x);
        for (y = [minY: maxY]) {
            left = x == minX;
            right = x == maxX;
            top = isTop(x, y);
            bottom = isBottom(x, y);

            applyKeyOffset(x, y)
            key(left, right, top, bottom);

            if (y < maxY) {
                colWidth = frame_size + (left || right ? frame_outline_width : 0);

                color(preview_colors ? plate_color : "cyan") hull() {
                    frameFrontFace(x, y);
                    frameBackFace(x, y + 1);
                }
            }

            if (hasKey(x + 1, y)) {
                color(preview_colors ? plate_color : "lime")
                hull() {
                    frameRightFace(x, y);
                    frameLeftFace(x + 1, y);
                }

                if (hasKey(x + 1, y + 1)) {
                    color(preview_colors ? plate_color : "purple")
                    hull() {
                        frameFrontRightCorner(x, y);
                        frameFrontLeftCorner(x + 1, y);
                        frameBackLeftCorner(x + 1, y + 1);
                        frameBackRightCorner(x, y + 1);
                    }
                }
            } else if (hasKey(x + 1, y + 1)) {
                color(preview_colors ? plate_color : "red")
                hull() {
                    frameFrontRightCorner(x, y);
                    frameBackLeftCorner(x + 1, y + 1);
                    frameBackRightCorner(x, y);
                }
                color(preview_colors ? plate_color : "yellow")
                hull() {
                    frameFrontRightCorner(x, y);
                    frameBackLeftCorner(x + 1, y + 1);
                    frameBackRightCorner(x, y + 1);
                }
            }
            if (isBottom(x, y) && hasKey(x + 1, y - 1)) {
                color(preview_colors ? plate_color : "blue")
                hull() {
                    frameBackRightCorner(x, y);
                    frameBackLeftCorner(x + 1, y - 1);
                    frameFrontLeftCorner(x + 1, y - 1);
                }
                color(preview_colors ? plate_color : "orange")
                hull() {
                    frameBackRightCorner(x, y);
                    frameBackLeftCorner(x + 1, y);
                    frameFrontLeftCorner(x + 1, y - 1);
                }
            }
        }
    }
}

module screwHole () {
    dk = 6;
    k = 1.7;
    d = 3;

    $fn = 30;
    translate([0, 0, -25])
    cylinder(100, d / 2, d / 2);
    cylinder(k, d / 2, dk / 2);
    translate([0, 0, k - e])
    cylinder(20, dk / 2, dk / 2);
}

screw_hole_wall_thickness = 1.2;

min_stem_length = 3.5;

main_hole_1_start = getKeyOffset(2,0) + rotate_vec([-frame_size / 2 - 1.5, -frame_size / 2 - 2, -.5], getKeyRotation(2,0));
main_hole_2_start = getKeyOffset(2,0) + rotate_vec([-frame_size / 2 - 1.5, +frame_size / 2 + 2, -.5], getKeyRotation(2,0));
main_hole_3_start = getKeyOffset(0,0) + rotate_vec([-frame_size / 2 - 1, -frame_size / 2 - 2, 3], getKeyRotation(2,0));
main_hole_4_start = getKeyOffset(0,0) + rotate_vec([-frame_size / 2 - 1, +frame_size / 2 + 2, 3], getKeyRotation(2,0));

main_hole_1_end = [main_hole_1_start.x + 20, main_hole_1_start.y - 5, -25];
main_hole_2_end = [main_hole_2_start.x + 20, main_hole_2_start.y + 5, -25];
main_hole_3_end = [main_hole_3_start.x - 2, main_hole_3_start.y - 1, -25];
main_hole_4_end = [main_hole_4_start.x - 2, main_hole_4_start.y + 1, -25];

main_hole_1_dir = dir_between_points(main_hole_1_end,main_hole_1_start);
main_hole_2_dir = dir_between_points(main_hole_2_end,main_hole_2_start);
main_hole_3_dir = dir_between_points(main_hole_3_end,main_hole_3_start);
main_hole_4_dir = dir_between_points(main_hole_4_end,main_hole_4_start);

main_beam_1_len = norm(main_hole_1_start-main_hole_1_end);
main_beam_2_len = norm(main_hole_2_start-main_hole_2_end);
main_beam_3_len = norm(main_hole_3_start-main_hole_3_end);
main_beam_4_len = norm(main_hole_4_start-main_hole_4_end);

main_spacer_1_len = floor((main_beam_1_len - min_stem_length * 2)/5) * 5;
main_spacer_2_len = floor((main_beam_2_len - min_stem_length * 2)/5) * 5;
main_spacer_3_len = floor((main_beam_3_len - min_stem_length * 2)/5) * 5;
main_spacer_4_len = floor((main_beam_4_len - min_stem_length * 2)/5) * 5;

main_stem_1_len = (main_beam_1_len - main_spacer_1_len) / 2;
main_stem_2_len = (main_beam_2_len - main_spacer_2_len) / 2;
main_stem_3_len = (main_beam_3_len - main_spacer_3_len) / 2;
main_stem_4_len = (main_beam_4_len - main_spacer_4_len) / 2;

echo("Main cluster 1 spacer length", main_spacer_1_len);
echo("Main cluster 2 spacer length", main_spacer_2_len);
echo("Main cluster 3 spacer length", main_spacer_3_len);
echo("Main cluster 4 spacer length", main_spacer_4_len);

module screwHole2(position, direction) {
    translate(position)
    rotate(dir_to_rot(direction))
    screwHole();
}

module stem (position, direction, length) {
    $fn = 30;
    extra_offset = 2; // extra offset backwards - we will cut into this with screw holes anyway
    translate(position)
    rotate(dir_to_rot(direction))
    translate([0,0,-extra_offset])
    cylinder(length+extra_offset,1.5 + screw_hole_wall_thickness,1.5 + screw_hole_wall_thickness);
}


module mainCluster () {
    difference() {
        union () {
            top();

            stem(main_hole_1_start, -main_hole_1_dir, main_stem_1_len);
            stem(main_hole_2_start, -main_hole_2_dir, main_stem_2_len);
            stem(main_hole_3_start, -main_hole_3_dir, main_stem_3_len);
            stem(main_hole_4_start, -main_hole_4_dir, main_stem_4_len);
        }

        screwHole2(main_hole_1_start, main_hole_1_dir);
        screwHole2(main_hole_2_start, main_hole_2_dir);
        screwHole2(main_hole_3_start, main_hole_3_dir);
        screwHole2(main_hole_4_start, main_hole_4_dir);
    }
}

spacer_radius = 3;

module spacers () {
    // main cluster spacers
     $fn = 6;
    color("silver")
    translate(main_hole_1_end)
    translate(main_hole_1_dir*main_stem_1_len)
    rotate(dir_to_rot(main_hole_1_dir))
    cylinder(main_spacer_1_len,spacer_radius,spacer_radius);

    color("silver")
    translate(main_hole_2_end)
    translate(main_hole_2_dir*main_stem_2_len)
    rotate(dir_to_rot(main_hole_2_dir))
    cylinder(main_spacer_2_len,spacer_radius,spacer_radius);

    color("silver")
    translate(main_hole_3_end)
    translate(main_hole_3_dir*main_stem_3_len)
    rotate(dir_to_rot(main_hole_3_dir))
    cylinder(main_spacer_3_len,spacer_radius,spacer_radius);

    color("silver")
    translate(main_hole_4_end)
    translate(main_hole_4_dir*main_stem_4_len)
    rotate(dir_to_rot(main_hole_4_dir))
    cylinder(main_spacer_4_len,spacer_radius,spacer_radius);
}


module thumbRightFace (x, y) {
    rowHeight = frame_size + frame_outline_width * 2;

    applyThumbOffset(x, y)
    translate([fOffset, 0, 0])
    cube([e, rowHeight, plate_thickness], center = true);
}

module thumbLeftFace (x, y) {
    rowHeight = frame_size + frame_outline_width * 2;

    applyThumbOffset(x, y)
    translate([-fOffset, 0, 0])
    cube([e, rowHeight, plate_thickness], center = true);
}

thumb_col_degrees = 30;
thumb_horizontal_key_spacing = 8;
thumb_twist_degrees = -12;

module applyThumbOffset(x, y) {
    // Calculate the transformed vector using the new method
    offset = getThumbKeyOffset(x, y);

    // Apply the final transformation (translate and rotate)
    translate(offset)
    rotate([y * row_degrees, 0, 0])
    rotate([0, -x * thumb_col_degrees, 0])
    rotate([0, 0, x * thumb_twist_degrees])
    children();
}

function getThumbKeyOffset(x, y) = 
    let(
        offs1 = chainRotationOffset(x, frame_size + thumb_horizontal_key_spacing, thumb_col_degrees),
        offs2 = chainRotationOffset(y, frame_size + vertical_key_spacing, row_degrees)
    )
    rotate_z([offs1[0], 0, offs1[1]], x * thumb_twist_degrees / 2) +
    [0, offs2[0], offs2[1]];


thumb_cluster_offset = [30,-51,25];
thumb_cluster_rotation = [25,15,-15];


thumb_hole_1_start = rotate_vec(getThumbKeyOffset(0,0) + [-12,0,plate_thickness/2-2], [40, 15, -15]) + [30, -51, 25];
thumb_hole_2_start = rotate_vec(getThumbKeyOffset(0,0) + [12,0,plate_thickness/2-2], [40, 15, -15]) + [30, -51, 25];
thumb_hole_1_end = [10, -25, -25];
thumb_hole_2_end = [15+20, -38, -25];
h1d = dir_between_points(thumb_hole_1_end,thumb_hole_1_start);
h2d = dir_between_points(thumb_hole_2_end,thumb_hole_2_start);

thumb_beam_1_len = norm(thumb_hole_1_start-thumb_hole_1_end);
thumb_beam_2_len = norm(thumb_hole_2_start-thumb_hole_2_end);

thumb_spacer_1_len = floor((thumb_beam_1_len - min_stem_length * 2)/5) * 5;
thumb_spacer_2_len = floor((thumb_beam_2_len - min_stem_length * 2)/5) * 5;

thumb_stem_1_len = (thumb_beam_1_len - thumb_spacer_1_len) / 2;
thumb_stem_2_len = (thumb_beam_2_len - thumb_spacer_2_len) / 2;

echo("Thumb cluster 1 spacer length", thumb_spacer_1_len);
echo("Thumb cluster 2 spacer length", thumb_spacer_2_len);

// Thumb cluster
module thumbCluster() {
    difference() {
        union () {
            translate(thumb_cluster_offset)
            rotate(thumb_cluster_rotation)
            for (x = [-1:1]) {
                applyThumbOffset(x,0)
                key(x == -1, x == 1, true, true);
                if (x < 1) {
                    color(preview_colors ? plate_color : "purple")
                    hull(){
                        thumbRightFace(x,0);
                        thumbLeftFace(x+1,0);
                    }
                }
            }

            $fn=30;
            translate(thumb_hole_1_start)
            rotate(dir_to_rot(-h1d))
            translate([0,0,-1])
            cylinder(thumb_stem_1_len+1,1.5 + screw_hole_wall_thickness,1.5 + screw_hole_wall_thickness);
            
            translate(thumb_hole_2_start)
            rotate(dir_to_rot(-h2d))
            translate([0,0,-1])
            cylinder(thumb_stem_2_len+1,1.5 + screw_hole_wall_thickness,1.5 + screw_hole_wall_thickness);
        }

        $fn=30;

        screwHole2(thumb_hole_1_start, h1d);
        screwHole2(thumb_hole_2_start, h2d);
    }
}

module thumbClusterSpacers () {
    // thumb cluster spacers
     $fn = 6;
    color("silver")
    translate(thumb_hole_1_end)
    translate(h1d*thumb_stem_1_len)
    rotate(dir_to_rot(h1d))
    cylinder(thumb_spacer_1_len,spacer_radius,spacer_radius);

    color("silver")
    translate(thumb_hole_2_end)
    translate(h2d*thumb_stem_2_len)
    rotate(dir_to_rot(h2d))
    cylinder(thumb_spacer_2_len,spacer_radius,spacer_radius);
}

module basePlate() {

    difference() {
        union () {
            $fn=100;
            hull () {
                translate([8+7,-6,-27])
                cylinder(h=2, d=120, center=true);
                translate([8+7,-6,-26])
                cylinder(h=4, d=105, center=true);

            }

            // Main cluster stems
            stem(main_hole_1_end, main_hole_1_dir, main_stem_1_len);
            stem(main_hole_2_end, main_hole_2_dir, main_stem_2_len);
            stem(main_hole_3_end, main_hole_3_dir, main_stem_3_len);
            stem(main_hole_4_end, main_hole_4_dir, main_stem_4_len);

            /*hull () {
                $fn = 30;
                translate(main_hole_1_end + [0,0,-1])
                cylinder(4, d=12, center=true);
                translate(main_hole_2_end + [0,0,-1])
                cylinder(4, d=12, center=true);
                translate(main_hole_3_end + [0,0,-1])
                cylinder(4, d=12, center=true);
                translate(main_hole_4_end + [0,0,-1])
                cylinder(4, d=12, center=true);
            }*/
            
            // thumb stems
            stem(thumb_hole_2_end, h2d, thumb_stem_2_len);
            stem(thumb_hole_1_end, h1d, thumb_stem_1_len);
            
            /*
            hull () {
                $fn = 30;
                translate(thumb_hole_1_end + [0,0,-1])
                cylinder(4, d=12, center=true);
                translate(thumb_hole_2_end + [0,0,-1])
                cylinder(4, d=12, center=true);
            }*/
            
            skirt_height = 5;
            skirt_thickness = 11;
            difference () {
                hull () {
                    translate([8+7,-6,-28 - skirt_height / 2 + .5])
                    cylinder(h=skirt_height-1, d=120, center=true);
                    
                    translate([8+7,-6,-28 - skirt_height / 2])
                    cylinder(h=skirt_height, d=118, center=true);
                }
                
                translate([8+7,-6,-28 - skirt_height / 2])
                cylinder(h=skirt_height+1, d=120 - skirt_thickness * 2, center=true);
            }
        }

        screwHole2(main_hole_1_end, -main_hole_1_dir);
        screwHole2(main_hole_2_end, -main_hole_2_dir);
        screwHole2(main_hole_3_end, -main_hole_3_dir);
        screwHole2(main_hole_4_end, -main_hole_4_dir);
        
        screwHole2(thumb_hole_1_end, -h1d);
        screwHole2(thumb_hole_2_end, -h2d);
        
        // wire hole
        translate([-18, -1, 0]) cylinder(100, 8, 8, true);
        
        // Pi pico cutout
        tape_thickness = 1;
        translate([8+7,-6,-28.5])
        rotate([0,0,-10])
        translate([0,24+7.5,-10 + 1.2])
        {
            color("purple") cube([24, 60, 21], true);
        }
        
        trrs_jack_cutout();
    }

}

function dir_between_points(p1, p2) =
    let (
        v = p2-p1,  // Vector from p1 to p2
        l = norm(v)  // Length of the vector
    ) 
    v/l;  // Normalize the vector to get the direction

function dir_to_rot(dir) =
    [0, atan2(sqrt(dir[0] * dir[0] + dir[1] * dir[1]), dir[2]), atan2(dir[1], dir[0])];

preview_colors = false;
plate_color = "silver";

black = "#333";
color(black) mainCluster();
color(black) thumbCluster();
color("orange") spacers();
color("orange") thumbClusterSpacers();
color(black) basePlate();

module pi () {
    tape_thickness = 1;
    translate([8+7,-6,-28.5 - tape_thickness + 1.2])
    rotate([0,0,-10])
    translate([0,23.5 + 7.5,0])
    {
        color("purple") cube([21, 54, 1], true);
        color("gray") translate([0,27-3.75,-2.1]) cube([9, 7.5, 3.2], true);
        
        // Usb connector
        //color("red") translate([0,27-3.75 + 9.5,-2.1]) cube([9, 7.5, 6.5], true);
    }
}

module trrs_jack_cutout () {
    translate([8+7,-6,-29.2 + 2.6 - 4 + 1.2])
    rotate([0,0,-55])
    {
        translate([0,46+5.1-2,-2.5])
        color("red") cube([6.45, 18, 5.2+5], true);
        
        translate([0,55,-4.95])
        color("yellow") cube([5.05, 10, 10], true);
        
        $fn=20;
        translate([0,46+5.1+10,.05])
        rotate([90,0,0])
        color("purple") cylinder(h=10, d = 5.05, center = true);
    }
}

//trrs_jack_cutout();

module trrs_jack () {
    translate([8+7,-6,-29.2 + 2.6 - 4 + 1.2])
    rotate([0,0,-55])
    translate([0,46+7.5,0])
    color("gold") cube([6.2, 14, 5.2], true);
}


pi();
//trrs_jack();

