
nom=getTitle();
dir=getDirectory("image");


nome=substring(nom, 0 , nom.length-9);
print(nome);

//run("Z Project...", "projection=[Max Intensity]");

//run("Gaussian Blur...", "sigma=4 stack");

//setForegroundColor(255, 255, 255);

//setAutoThreshold("RenyiEntropy dark");
//setTool("wand");


//waitForUser("Choose the ROIs", "Draw the ROI and t them in the ROI manager");

//roiManager("Add");
roiManager("Deselect");
roiManager("Save", dir+nome+"_RoiSet.zip");

roiManager("Delete");
//close();
close();
