// Radial Distance Profiling Macro with Center Marking
// 1) Binarization -> Outline extraction
// 2) Input center coordinates
// 3) Duplicate image with center marked in red
// 4) Return to original image, radial scan in 500 directions -> Angle vs Distance plot

// Number of sampling points
nPoints = 5000;

// Get image dimensions & check active image
width  = getWidth();
height = getHeight();
if (width==0 || height==0)
    exit("Error: No active image.");

// Create filled binary mask & extract contour only
run("Make Binary");
run("Outline");

// Input center coordinates
cx = getNumber("Enter center X:", width/2);
cy = getNumber("Enter center Y:", height/2);

// Create image with center position marked in red
origTitle = getTitle();
run("Duplicate...", "title=Marked-Center");
setColor(255,0,0);
setLineWidth(5);
makePoint(cx, cy);
run("Draw");
// Return focus to original image
selectWindow(origTitle);

// Calculate maximum radius (image diagonal length)
maxR = sqrt(width*width + height*height);

// Allocate arrays for storing results
angles = newArray(nPoints);
radii  = newArray(nPoints);

// Measure distance to membrane at each angle
for (i = 0; i < nPoints; i++) {
    angle = 2 * PI * i / nPoints;
    angles[i] = angle * 180 / PI;
    radii[i] = 0;
    for (r = 0; r <= maxR; r++) {
        x = cx + r * cos(angle);
        y = cy + r * sin(angle);
        if (x < 0 || x >= width || y < 0 || y >= height)
            break;
        // In binarized image, membrane pixel value is 255
        if (getPixel(round(x), round(y)) > 0) {
            radii[i] = r;
            break;
        }
    }
}

// Create and display Angle vs Distance plot
Plot.create("Angle vs Distance", "Angle (°)", "Distance (px)", angles, radii);
Plot.show();