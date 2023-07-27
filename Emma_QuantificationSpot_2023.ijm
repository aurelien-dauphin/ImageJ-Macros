/*
 * Get the images registered "res_..._ch1.tif" ch_2 and ch_3.tif
 * Get the ROI in the same folder, after usig Emma_ROI macro, in "res_..._RoiSet.zip"
 * Get the mask with the nucleux in the same folder, using the macro Emma_Nucleus_Mask_2023. It produce the ch_0_nucleus mask
 * 
 * Get threshold
 * DOUBLE THE DEFAULT THRESHOLD
 * Crop the ROI, clean outside
 * Use 3D Object counter
 * 
 * Make a tab results and save it
 * Save the object image
 * 
 */

Chquant=3; //channel de quantif, 1 bleu, 2 vert, 3 rouge  
 
chN=1; //1 only if you made mask with the nucleux with the macro Emma_Nucleus_Mask_2023. 
chA=2;
chB=3;
colocvolumexy=120;
colocvolumez=340;
lowerA=9500;
lowerB=3000;
minlowA=1800;
minlowB=2500;

dir=getDirectory("Choose a Directory for 3D Objects counting");
dir2=getDirectory("Choose a Directory for 3D Objects counting results");
listeFichiers=getFileList(dir);
nFichiers=listeFichiers.length;



nom=newArray(0);
npart=newArray(0);

sommenpart=0;
vol=newArray(0);
vox=newArray(0);
moyenne=newArray(0);
k=0;
max=0;

k=0;


//							--------------------File loop l----------------------
for (l = 0; l < nFichiers; l++)  
{
	
//--------------------Make a composite with nucleus's mask, ch2 and ch3 cropped and renamed roi_1, roi_2...--------
	if (chN==1) 
	{
		if (endsWith(listeFichiers[l], "_ch_0_nucleus_mask.tif")) 
		{
			open(dir+listeFichiers[l]);
			nome=getTitle();
			nomeim=substring(nome, 4 , nome.length-22);	
			print(" ");
			print(" ");
			print("########################### I open the nucleus : "+l+" / "+ round(nFichiers));
			print(nomeim);
			rename("wnucleus");
			nZ=nSlices;
			midZ=round(nZ/2);
			//waitForUser;

		//---open the 2 colors and multiply with the mask of the nucleus	
			open(dir+"res_"+nomeim+"_ch_2.tif");
run("Properties...", "channels=1 slices="+nZ+" frames=1 pixel_width=0.0395000 pixel_height=0.0395000 voxel_depth=0.1250000");//$$$$$$$$$$$$$$$$$$$$$$$$$
			rename("wch2_raw");
			imageCalculator("Multiply create stack", "wch2_raw", "wnucleus");
				//rename(nomidquant+"_Wch"+Chquant);
			rename("wch2");
			open(dir+"res_"+nomeim+"_ch_3.tif");
			rename("wch3_raw");
			imageCalculator("Multiply create stack", "wch3_raw", "wnucleus");
			//wait(1200);
			rename("wch3");
			
		
		// ----- close the images useless	
			selectWindow("wnucleus");
		  	close();
		  	selectWindow("wch3_raw"); ///
		  		close();
		  	selectWindow("wch2_raw");
		  		close();
		  	if(Chquant==2) {selectWindow("wch3"); ///
		  					close();
		  					}
			if(Chquant==3) {selectWindow("wch2"); ///
							close();
							}
		// ---- print the channel for quantification
		  	print("Quantified Channel : "+Chquant);
		  	
	  	//					-----Threshold-----
		resetThreshold();
		//setAutoThreshold("Moments dark stack");
		setAutoThreshold("Default dark stack"); // ON DOUBLE LE SEUIL
		getThreshold(lower, upper);
		//waitForUser("Como esta el Threshold ? esta "+lower+"/n Cambialo si necesitas");
		//getThreshold(lower, upper);
		lower=lower*2;  
		
		print(nomeim+" threshold Channel "+Chquant+" : "+lower);
					
		
		
		// ---- Open the roi
			roiManager("Open", dir+"res_"+nomeim+"_RoiSet.zip");
			nRoi=roiManager("count");	
		// ---- make image duplicates	named roi_1, roi_2...
			for (j = 0; j < nRoi; j++) 
			{
				selectWindow("wch"+Chquant);
				roiManager("Deselect");
				roiManager("Select", j);
				
				run("Duplicate...", "title=roi_"+j+" duplicate stack");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside", "stack");
				run("Select None");
				rename("roi_"+j);
				
			}				
				roiManager("reset");
				
		  		selectWindow("wch"+Chquant);
		  		close();	
				
		  								
//------------------Quantification of the spots dans chaque image-roi----------	
			for (i = 0; i < nRoi; i++) 
			{
			selectWindow("roi_"+i);	
			run("Select None");
			setSlice(midZ);
			resetMinAndMax();
			
			selectWindow("roi_"+i);	
			
			run("3D Objects Counter", "threshold="+lower+" slice="+midZ+" min.=0 max.=159768832 objects statistics summary");
			//saveAs("Results", dir2+nomid2+"_Stat.csv");
			//waitForUser("Copy the result table");
			Table.rename("Statistics for roi_"+i, "Results");

			// 			-------------------Fill the arrays------------
			vol1=newArray(nResults);
			vox1=newArray(nResults);
			moyenne1=newArray(nResults);
			nom1=newArray(1);
			npart1=newArray(1);
			nom1[0]=nomeim+"_roi_"+i+"_Wch"+Chquant;
			
			sommenpart=sommenpart+nResults;
			npart1[0]=sommenpart;
			if (nResults>max) {max=nResults;}

					for (j = 0; j < nResults; j++) 
								{
							   vol1[j]=getResult("Volume (micron^3)", j);
								vox1[j]=getResult("Nb of obj. voxels", j);
								moyenne1[j]=getResult("Mean", j);
								}
					nom=Array.concat(nom,nom1);			
					npart=Array.concat(npart,npart1);
					vol=Array.concat(vol,vol1);
					vox=Array.concat(vox,vox1);
					moyenne=Array.concat(moyenne,moyenne1);

selectWindow("Objects map of roi_"+i);
saveAs("Tiff", dir2+nomeim+"_roi"+i+"_Objects_map_ch"+Chquant+".tif");
			k=k+1;
			selectWindow("roi_"+i);	
			close();
			}
	
		}
run("Close All");
	}
}
//			------------Final Results----------

Titre="[Bilan]";
run("New... ", "name="+Titre+" type=Table");
header="";

 			for (l = 0; l < k; l++) {
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
				for (o = 0; o < k; o++) {
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


