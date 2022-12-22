/* Macro pour detection de spots en 3D pour Laia et Daniel
 *  Masque sur le noyau bleu, ch1
 *  Spots en vert, ch2
 *  Spot en rouge, ch3
 *  Chquant est le channel a quantifier (nombre taille et intensité de foci)
 *  Z registration du bleu par rapport au vert (Blue 12, Green 14, Red 15) 
 *  Masque du dapi sur le channel à analyser
 *  Normalisation
 *  Threshold automatic
 *  3D Oject counter
 *  array et tableau de resultat, par 3 colonnes pour chaque Image, mis bouts à bouts
 *  Aurelien.dauphin@curie.fr
 */
Chquant=3; //channel de quantif, 1 bleu, 2 vert, 3 rouge

run("Set Measurements...", "area mean standard integrated redirect=None decimal=3");
run("3D OC Options", "volume nb_of_obj._voxels mean_gray_value centre_of_mass dots_size=1 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");


dir=getDirectory("Choose a Directory for 3D Objects counting");
dir2=getDirectory("Choose a Directory for 3D Objects counting results");
listeFichiers=getFileList(dir);
nFichiers=listeFichiers.length;


nom=newArray(nFichiers);
npart=newArray(nFichiers);
sommenpart=0;
vol=newArray(0);
vox=newArray(0);
moyenne=newArray(0);
k=0;
max=0;

//							--------------------File loop----------------------
for (i = 0; i < nFichiers; i++)  {

run("Bio-Formats", "open="+dir+listeFichiers[i]+" color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");


nom[i]=getTitle();
Stack.getDimensions(width, height, channels, slices, frames) ;
//Chquant=3; ///
bit=bitDepth(); 
nZ=slices;
midZ=round(nZ/2);
//print(nZ);
print("Quantified Channel : "+Chquant);
run("Split Channels");
if (channels == 3) {
id3=getImageID();
id2=id3+2;
id1=id2+2;
}
if (channels == 2) {
id2=getImageID();
id1=id2+2;
}
if (Chquant==2) {
selectImage(id2);
nomidquant = getTitle();
}
if (Chquant==3) {
selectImage(id3);
nomidquant = getTitle();
}
print("image to quantify : "+nomidquant);

selectImage(id1);

run("Duplicate...", "duplicate");
rename("Wch1");

setSlice(midZ);
resetMinAndMax();


// -------------------Registration add 2 slices at the begining, remove 2 (dif) at the end of channel 1---------------- 
	/*	width=getWidth();
height=getHeight();
bit=bitDepth();
nZ=nSlices;
				print(nZ);
			*/	
				dif=-2;
				newImage("pre", ""+bit+"-bit Black", width, height, -dif);
				run("Concatenate...", "stack1=pre stack2=Wch1 title=Wch1_reg");
				selectWindow("Wch1_reg");
				run("Slice Remover", "first="+(nZ+dif+1)+" last="+nZ+" increment=1");

//run("8-bit");
//run("Sharpen", "stack");
//resetMinAndMax();
selectWindow("Wch1_reg");
//waitForUser("Nucleus ?"); //
run("Find Edges", "stack");

run("Gaussian Blur...", "sigma=5 stack");
//waitForUser("blur Nucleus ?"); ///
setSlice(midZ);
setAutoThreshold("Huang dark stack");
//waitForUser("Is the Threshold fine for the nucleus?"); //
//setThreshold(19, 255);
run("Convert to Mask", "method=Default background=Dark");
run("Fill Holes", "stack");
saveAs("Tiff", dir2+nom[i]+"_nucleus_mask.tif");
run("Subtract...", "value=254 stack");
rename("nucleus");

imageCalculator("Multiply create stack", nomidquant, "nucleus");
rename(nomidquant+"_Wch"+Chquant);



//										-------- Normalisation------

setSlice(midZ);

		max2=0;
		min2=1000000;
			for(azera=1; azera<=nZ; azera++)
				{
		
		
		//print("area " + azera);
		//Stack.setSlice(azera);
		
		setSlice(azera);	
		getStatistics(area, mean, mintemp2, maxtemp2, std, histogram);		
		//print("mintemp2" +mintemp2); 
		
		if (maxtemp2>=max2) max2=maxtemp2; 
		if (mintemp2<=min2) min2=mintemp2; 
				
					}
			print("Channels "+Chquant+" "+nomidquant+" min et max : "+min2+" "+max2);
			setMinAndMax(min2, max2);
			run("16-bit");

//					-----Threshold-----
setAutoThreshold("Moments dark stack");
setSlice(midZ);
//waitForUser("Como esta el Threshold ?/n Cambialo si necesitas");
getThreshold(lower, upper);
print(nom[i]+" threshold Channel2 : "+lower);
resetThreshold();				


run("3D Objects Counter", "threshold="+lower+" slice="+midZ+" min.=0 max.=159768832 objects statistics summary");
//saveAs("Results", dir2+nomid2+"_Stat.csv");
//waitForUser("Copy the result table");
Table.rename("Statistics for "+nomidquant+"_Wch"+Chquant, "Results");

// 			-------------------Fill the arrays------------
vol1=newArray(nResults);
vox1=newArray(nResults);
moyenne1=newArray(nResults);
npart[i]=sommenpart+nResults;
sommenpart=npart[i];
if (nResults>max) {max=nResults;}

for (j = 0; j < nResults; j++) {
   vol1[j]=getResult("Volume (micron^3)", j);
	vox1[j]=getResult("Nb of obj. voxels", j);
	moyenne1[j]=getResult("Mean", j);
  // print("vol1 = "+vol1[j]);
   
}

//print("nresults de "+nomid2+" = "+nResults);
vol=Array.concat(vol,vol1);
vox=Array.concat(vox,vox1);
moyenne=Array.concat(moyenne,moyenne1);



selectWindow("Objects map of "+nomidquant+"_Wch"+Chquant);
saveAs("Tiff", dir2+nomidquant+"_Objects_map.tif");
run("Close All");
////////faire close results

}

//			------------Final Results----------

Titre="[Bilan]";
run("New... ", "name="+Titre+" type=Table");
header="";

 			for (l = 0; l < nFichiers; l++) {
 				header=header+"Vol_ch"+Chquant+"_"+nom[l]+"\t nbVox "+nom[l]+"\t mean "+nom[l]+"\t ";
 			}
print(Titre, "\\Headings:"+header);

p=0;
m=0;

//print("max data = "+max+"\t nfichiers ="+nFichiers);


for(cpt=0; cpt<max; cpt++)
{
//je remplis de nouvelles lignes à chaque nouvel échantillon
		Rez="";	
		m=0;
				for (o = 0; o < nFichiers; o++) {
					//print("npart de "+o+" est "+npart[o]+" et m+cpt = "+m+cpt);
 				if ((m+cpt)<npart[o]) 
					Rez=Rez+vol[m+cpt]+"\t"+vox[m+cpt]+"\t"+moyenne[m+cpt]+"\t";
					else 
 						 Rez=Rez+"\t"+"\t"+"\t"; 
 				m=npart[o];
 				
 				//print("m = "+m+"\t cpt = "+cpt);
 				

 			}
                
                print(Titre, Rez) ;
}
saveAs("Results", dir2+nom[0]+"_to_"+nom[o-1]+"_Batch_Stat_ch"+Chquant+".csv");
selectWindow("Log");
saveAs("Text", dir2+nom[0]+"_to_"+nom[o-1]+"_Batch_Log_ch"+Chquant+".txt");
print("The end");