// --- 0. Check if image is open ---
if (nImages < 1)
    exit("Error: No image is open.");

// --- 1. User input ---
// Input is in degrees: 3 o'clock = 0°, 6 o'clock = 90°, 9 o'clock = 180°, 12 o'clock = 270°
// Get centroid coordinates and angle
xC    = getNumber("Please enter the cell centroid X coordinate (px)", 100);
yC    = getNumber("Please enter the cell centroid Y coordinate (px)", 100);
angle = getNumber("Please enter the measurement angle (degrees, 3 o'clock = 0°, clockwise positive)", 0);

// --- 2. Get image information ---
getDimensions(width, height, channels, slices, frames);
numSlices = frames;  // Number of time-lapse frames

// --- 3. Mask generation & contour extraction ---
run("Duplicate...", "title=Processed duplicate range=1-" + numSlices);
selectWindow("Processed");
run("8-bit");
run("Gaussian Blur...", "sigma=1 stack");
setAutoThreshold("Li dark stack");
run("Convert to Mask", "stack");
run("Close-", "stack");
run("Fill Holes", "stack");
// Extract contour only
run("Outline", "stack");

// --- 4. Prepare Results table ---
// Uncomment to clear previous results
// run("Clear Results");
startRow = nResults;

// --- 5. Angle conversion (3 o'clock = 0°, clockwise positive) ---
theta = angle * PI / 180.0;
cosT  = cos(theta);
sinT  = sin(theta);

// --- 6. Measure distance for each slice & store in Results ---
for (slice = 1; slice <= numSlices; slice++) {
    setSlice(slice);
    maxLen = sqrt(width*width + height*height);
    distPx = 0;
    for (r = 0; r <= maxLen; r++) {
        x = xC + r * cosT;
        y = yC + r * sinT;
        if (x < 0 || x >= width || y < 0 || y >= height)
            break;
        v = getPixel(round(x), round(y));
        if (v > 0) {  // When hitting a contour pixel
            distPx = r;
            break;
        }
    }
    row = startRow + slice - 1;
    setResult("Slice",         row, slice);
    setResult("Distance (px)", row, distPx);
}

// --- 7. Update & display table ---
updateResults();
selectWindow("Results");