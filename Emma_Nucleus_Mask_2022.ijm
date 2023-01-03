/*
 * Make mask with nucleus images on ch1
 * 
 */

chN=1;
chA=2;
chB=3;
colocvolumexy=120;
colocvolumez=300;

dir=getDirectory("Choose a Directory with the objects, including the nucleus as chN=1");
//dir2=getDirectory("Choose a Directory for results");
listeFichiers=getFileList(dir);
nFichiers=listeFichiers.length;




// ------------MAKE MASK OF NUCLEUS---------------
//							--------------------File loop----------------------
for (i = 0; i < nFichiers; i++)  
{
	
//							--------------------Mask of the nucleus--------
	if (chN==1) {
				if (endsWith(listeFichiers[i], "_ch_"+chN+".tif")) {
					open(dir+listeFichiers[i]);
				nome=getTitle();
				nZ=nSlices;
				midZ=round(nZ/2);

				nomeim=substring(nome, 0 , nome.length-9);	
				run("Find Edges", "stack");

				run("Gaussian Blur...", "sigma=5 stack");
				setSlice(midZ);
				setAutoThreshold("Default dark stack");
				waitForUser("Is the Threshold fine for the nucleus?"); //
				run("Convert to Mask", "method=Default background=Dark");
				run("Fill Holes", "stack");
				//saveAs("Tiff", dir+nom[i]+"_nucleus_mask.tif");
				run("Subtract...", "value=254 stack");
				rename("nucleus");
				//print("nom " +nomeim)
				saveAs("Tiff", dir+nomeim+"_ch_0_nucleus_mask.tif");
				close();
				
				
				//imageCalculator("Multiply create stack", nomidquant, "nucleus");
				//rename(nomidquant+"_Wch"+Chquant);

					
				
				
																	}
				} else { print("ch0 is not the nucleus ?"); }
}