// Macro to perform a sequence of processing on all stacks
// 1) Convert to 8-bit  
// 2) Gaussian Blur σ=1 (entire stack)  
// 3) Threshold with Li method (entire stack) -> Convert to Mask (entire stack)  
// 4) Morphology: Close & Fill Holes (entire stack)  
// 5) Extract sub-stack for slices 1–3 / 4–15  
// 6) Max Intensity Projection  

// Duplicate original image as "Processed"
origTitle = getTitle();
run("Duplicate...", "title=Processed_2 duplicate range=1-120");
selectWindow("Processed_2");

// 1) Convert to 8-bit (entire stack)
run("8-bit");

// 2) Apply Gaussian Blur σ=1 to the entire stack
run("Gaussian Blur...", "sigma=1 stack");

// 3) Set threshold using Li method for the entire stack -> Convert to true binary mask
setAutoThreshold("Li dark stack");
run("Convert to Mask", "stack");

// 4) Morphological operations: Close & Fill Holes (both applied to the entire stack)
run("Close-", "stack");
run("Fill Holes", "stack");

// 5) Extract first half (slices 1-120) sub-stack -> Max Intensity Projection
run("Slice Keeper", "first=1 last=120 increment=1");
run("Analyze Particles...", "size=200-Infinity display add stack");

// Added right after step 5: Shrink all detected ROIs inward and update in ROI Manager
count = roiManager("count");
if (count==0) exit("No ROIs were found (please review the Analyze Particles parameters).");

for (i=0; i<count; i++) {
    roiManager("Select", i);                     // Select ROI i
    run("Enlarge...", "enlarge=-2.2");             // ★ Shrink inward (negative value)
    run("Make Band...", "band=2");
    roiManager("Update");                        // Overwrite and save shape (preserves slice association)
    // Optional: Append _in5 to the name for clarity
    // name = roiManager("Get Name");             // May not work in some environments
    // roiManager("Rename", "ROI"+i+"_in5");      // Rename if necessary
}
roiManager("Show All with labels");
print("Done: All detected contours were shrunk inward by 5 px and updated in ROI Manager.");