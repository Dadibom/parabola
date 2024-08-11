// Rotation matrix around the X-axis
function rotX(angle) = [
    [1, 0, 0],
    [0, cos(angle), -sin(angle)],
    [0, sin(angle), cos(angle)]
];

// Rotation matrix around the Y-axis
function rotY(angle) = [
    [cos(angle), 0, sin(angle)],
    [0, 1, 0],
    [-sin(angle), 0, cos(angle)]
];

// Rotation matrix around the Z-axis
function rotZ(angle) = [
    [cos(angle), -sin(angle), 0],
    [sin(angle), cos(angle), 0],
    [0, 0, 1]
];

// Multiply two 3x3 matrices
function mat_mult(A, B) = [
    [
        A[0][0]*B[0][0] + A[0][1]*B[1][0] + A[0][2]*B[2][0],
        A[0][0]*B[0][1] + A[0][1]*B[1][1] + A[0][2]*B[2][1],
        A[0][0]*B[0][2] + A[0][1]*B[1][2] + A[0][2]*B[2][2]
    ],
    [
        A[1][0]*B[0][0] + A[1][1]*B[1][0] + A[1][2]*B[2][0],
        A[1][0]*B[0][1] + A[1][1]*B[1][1] + A[1][2]*B[2][1],
        A[1][0]*B[0][2] + A[1][1]*B[1][2] + A[1][2]*B[2][2]
    ],
    [
        A[2][0]*B[0][0] + A[2][1]*B[1][0] + A[2][2]*B[2][0],
        A[2][0]*B[0][1] + A[2][1]*B[1][1] + A[2][2]*B[2][1],
        A[2][0]*B[0][2] + A[2][1]*B[1][2] + A[2][2]*B[2][2]
    ]
];

// Convert Euler angles to a rotation matrix
function euler_to_matrix(euler) = mat_mult(mat_mult(rotZ(euler[2]), rotY(euler[1])), rotX(euler[0]));

// Convert a rotation matrix back to Euler angles
function matrix_to_euler(m) = [
    atan2(m[2][1], m[2][2]),         // Rotation around X-axis
    atan2(-m[2][0], sqrt(m[2][1]*m[2][1] + m[2][2]*m[2][2])), // Rotation around Y-axis
    atan2(m[1][0], m[0][0])          // Rotation around Z-axis
];

// Combine two Euler angle vectors
function combine_rotations(a, b) =
    let(
        // Convert both Euler angle sets to matrices
        matrix_a = euler_to_matrix(a),
        matrix_b = euler_to_matrix(b),
        
        // Combine the rotation matrices
        combined_matrix = mat_mult(matrix_b, matrix_a)
    )
    // Convert the combined rotation matrix back to Euler angles
    matrix_to_euler(combined_matrix);

    // Helper function to apply a 3D rotation around the Z-axis
function rotate_z(v, angle) = [
    v[0] * cos(angle) - v[1] * sin(angle),
    v[0] * sin(angle) + v[1] * cos(angle),
    v[2]
];

// Helper function to apply a 3D rotation around the Y-axis
function rotate_y(v, angle) = [
    v[0] * cos(angle) + v[2] * sin(angle),
    v[1],
    -v[0] * sin(angle) + v[2] * cos(angle)
];

// Helper function to apply a 3D rotation around the X-axis
function rotate_x(v, angle) = [
    v[0],
    v[1] * cos(angle) - v[2] * sin(angle),
    v[1] * sin(angle) + v[2] * cos(angle)
];

// Function to rotate a vector around the X, Y, and Z axes
function rotate_vec(v, angles) =
    rotate_z(
        rotate_y(
            rotate_x(v, angles[0]),  // Rotate around X-axis first
            angles[1]                // Then rotate around Y-axis
        ),
        angles[2]                    // Finally rotate around Z-axis
    );

// Function to perform a translation
function translate_vec(v, t) = [
    v[0] + t[0],
    v[1] + t[1],
    v[2] + t[2]
];

function chainRotationOffset(col, segmentLength, segmentAngle) =
col == 0 ? [0, 0] :
    let(
        prev = chainRotationOffset(col > 0 ? col - 1 : col + 1, segmentLength, segmentAngle),
        abs_col = abs(col),
        angle1 = segmentAngle * (abs_col - 1),
        angle2 = segmentAngle * abs_col
    )
    [
    prev[0] + cos(angle1) * segmentLength / 2 * sign(col) + cos(angle2) * segmentLength / 2 * sign(col),
    prev[1] + sin(angle1) * segmentLength / 2 + sin(angle2) * segmentLength / 2
    ];