// === Arc 170–190° from existing contour ROI (all frames, fixed centroid, inner -5 px) ===
// Prerequisite: Contour ROIs are stored in frame order in the ROI Manager.
// Output: Extract only the 170–190° arc from each frame's contour ROI -> Enlarge -5 px -> Add to ROI Manager & associate with that frame.

macro "Arc 165–195 (fixed centroid, inner-10, debug)" {

    // --- image info ---
    title = getTitle();
    getDimensions(w,h,c,z,t); // width, height, channels, slices, frames

    // Determine total (using if/else since ternary operator is not supported)
    if (t > 1) {
        total = t;
        isTime = true;
    } else {
        total = z;
        isTime = false;
    }

    print("\\Clear");
    print("DEBUG: title="+title+", c="+c+", z="+z+", t="+t+" -> total="+total+" (isTime="+isTime+")");

    // --- fixed centroid ---
    Dialog.create("Fixed centroid for all frames");
    Dialog.addNumber("Centroid X (pixels)", 0);
    Dialog.addNumber("Centroid Y (pixels)", 0);
    Dialog.show();
    cx = Dialog.getNumber();
    cy = Dialog.getNumber();
    if (cx==0 && cy==0) exit("Please enter the centroid (Centroid X/Y).");

    // --- constants ---
    startDeg = 170;
    endDeg   = 190;
    wrapHi   = endDeg - 360;  // 195 -> -165
    innerPx  = 0;             // Inward offset

    baseCount = roiManager("count");
    if (baseCount < total) {
        print("WARN: Original ROI count in ROI Manager ("+baseCount+") < total frames ("+total+")");
    }

    // --- loop ---
    for (f=1; f<=total; f++) {

        // 1) move to frame/slice
        selectWindow(title);
        if (isTime) {
            Stack.setFrame(f);
            print("DEBUG: Frame "+f+" / "+total);
        } else {
            setSlice(f);
            print("DEBUG: Slice "+f+" / "+total);
        }

        // 2) pick corresponding source ROI
        idx = f-1;
        if (idx >= 0 && idx < roiManager("count")) {
            roiManager("Select", idx);
        } else {
            print("WARN: plane "+f+" : Original ROI index "+idx+" does not exist. Skipping.");
            continue;
        }
        if (selectionType == -1) {
            print("WARN: plane "+f+" : ROI not selected. Skipping.");
            continue;
        }

        // 3) filter by angle
        getSelectionCoordinates(x, y);
        n = x.length;
        newX = newArray(0); newY = newArray(0);
        for (i=0; i<n; i++) {
            ang = 180 * atan2(y[i]-cy, x[i]-cx) / PI;
            inside = (ang >= startDeg) || (ang <= wrapHi);
            if (inside) {
                newX = Array.concat(newX, x[i]);
                newY = Array.concat(newY, y[i]);
            }
        }
        if (newX.length < 3) {
            print("WARN: plane "+f+" : Insufficient points within 170–190°");
            continue;
        }

        // 4) make arc ROI + inner offset
        makeSelection("polygon", newX, newY);
		
        // 5) add to ROI Manager & associate to this plane
        roiManager("Add");
        last = roiManager("count") - 1;
        roiManager("Select", last);
        run("Properties...", "slice="+f);

        // --- Create label using if/else ---
        if (isTime) {
            label = "F"+f+"_arc_170to190_in5";
        } else {
            label = "Z"+f+"_arc_170to190_in5";
        }
        roiManager("Rename", label);

        print("OK: plane "+f+" → ROI '"+label+"'");
    }

    roiManager("Show All with labels");
    print("DONE: processed "+total+" planes.");
}