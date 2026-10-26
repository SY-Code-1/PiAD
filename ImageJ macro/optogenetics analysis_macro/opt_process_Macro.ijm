// Macro to perform a sequence of processing on all stacks
// 1) Convert to 8-bit  
// 2) Gaussian Blur σ=1 (entire stack)  
// 3) Threshold with Li method (entire stack) -> Convert to Mask (entire stack)  
// 4) Morphological operations: Close & Fill Holes (entire stack)  
// 5) Extract sub-stack for slices 1–3 / 4–15  
// 6) Max Intensity Projection  

// Duplicate original image as "Processed"
origTitle = getTitle();
run("Duplicate...", "title=Processed_2 duplicate range=1-25");
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

// 5) Extract first half (slices 1-3) sub-stack -> Max Intensity Projection
run("Slice Keeper", "first=1 last=1 increment=1");
run("Analyze Particles...", "size=300-Infinity display add stack");

// 6) Return to "Processed" stack, extract second half (slices 13-15) -> Projection
selectWindow("Processed_2");
run("Slice Keeper", "first=5 last=7 increment=1");
run("Z Project...", "projection=[Max Intensity] title=Proj_13-15");