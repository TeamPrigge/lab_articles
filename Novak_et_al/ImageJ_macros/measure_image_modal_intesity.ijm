// Go to Analyze > Set Measurements... and tick Modal gray value. Untick everything else. Click OK

function measure1(input, filename){
	open(input + filename);
	setOption("ScaleConversions", true);
	run("8-bit");
	run("Select All");
	run("Measure");
	close();
}

input = "C:/Documents/histology/images/BF/" // Change this path. This is the path to the bright-field image folder.

list = getFileList(input);
for (i = 0; i < list.length; i++){
        measure1(input, list[i]);
}
