// Go to Analyze > Set Measurements... and tick Mean gray value. Untick everything else. Click OK

function roi_per_cell(input, filename){
	open(input + filename);
	setThreshold(0, 0);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Invert LUT");
	run("Watershed");
	run("Analyze Particles...", "add");
	run("Select All");
	close();
}

function multimeasure(input, filename){
	open(input + filename);
	run("8-bit");
	run("Grays");
	run("Select All");
	roiManager("Multi Measure");
	roiManager("Deselect");
	roiManager("Delete");
	close();
}

input1 = "C:/Documents/histology/masks/TH_masks/" // Change this path. This is the path to the TH mask folder.
input2 = "C:/Documents/histology/images/BF/" // Change this path. This is the path to the bright-field image folder.
output = "C:/Documents/histology/results/" // Change this path. This is the path to the folder where you store the results.

list1 = getFileList(input1);
list2 = getFileList(input2);
for (i = 0; i < list1.length; i++){ 
        roi_per_cell(input1, list1[i]);
		multimeasure(input2, list2[i]);
		String.copyResults();
		string = String.paste();
		File.append(string, output + "Results.csv");
}
