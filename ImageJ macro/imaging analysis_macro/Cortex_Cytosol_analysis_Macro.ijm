// Duplicate original image as "Processed"
origTitle = getTitle();
run("Duplicate...", "title=Processed_2 duplicate");
selectWindow("Processed_2");

// 1) Convert to 8-bit (entire stack)
run("8-bit");

// 2) Apply Gaussian Blur σ=1 to the entire stack
run("Gaussian Blur...", "sigma=1");

// 3) Set threshold using Li method for the entire stack -> Convert to true binary mask
setAutoThreshold("Li dark");
run("Convert to Mask");

// 4) Morphological operations: Close & Fill Holes (both applied to the entire stack)
run("Close-");
run("Fill Holes");
run("Watershed");

// 5) Extract first half (slices 1-123) sub-stack -> Max Intensity Projection
run("Analyze Particles...", "size=150-Infinity display add stack");

// Added right after step 5: Shrink all detected ROIs inward and update in ROI Manager
count = roiManager("count");
if (count==0) exit("No ROIs were found (please review the Analyze Particles parameters).");

for (i=0; i<count; i++) {
    // Inner cytosol ROI
    roiManager("Select", i);                     // Select ROI i
    run("Enlarge...", "enlarge=-1.5");             // ★ Shrink inward (negative value)
    roiManager("add");  // Add shape (preserves slice association)
    newIndex = roiManager("count") - 1;       // Index of the newly added ROI (last)
    roiManager("Select", newIndex);     
    roiManager("Rename", "cytosol"+i);
    
    // Cortex ROI
    roiManager("Select", i);                     // Select ROI i
    run("Enlarge...", "enlarge=-1.5");             // ★ Shrink inward (negative value)
    run("Make Band...", "band=1.5");
    roiManager("add");  // Add shape (preserves slice association)
    newIndex = roiManager("count") - 1;       // Index of the newly added ROI (last)
    roiManager("Select", newIndex); 
    roiManager("Rename", "cortex"+i);
    
}

roiManager("Show All with labels");
print("Done: All detected contours were shrunk inward by 5 px and updated in ROI Manager.");