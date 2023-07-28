/*
 * 
 * Get the ROI in the same folder, after usig Emma_ROI macro, in "res_..._RoiSet.zip"
 * Get the mask with the nucleux in the same folder, using the macro Emma_Nucleus_Mask_2023. It produce the ch_0_nucleus mask
 * 
 * 
 * 
 * Make a tab results and save it
 * 
 */
 
 
chN=1; //1 only if you made mask with the nucleux with the macro Emma_Nucleus_Mask_2023. 
chA=2;
chB=3;
colocvolumexy=120;
colocvolumez=340;
lowerA=9500;
lowerB=3000;
minlowA=3000;
minlowB=3000;

dir=getDirectory("Choose a Directory with the nucleus as ch_0");
dir2=getDirectory("Choose a Directory for results");
listeFichiers=getFileList(dir);
nFichiers=listeFichiers.length;
print(dir);
dirname=substring(dir, lastIndexOf(dir, "/202307_")+8, lastIndexOf(dir, "/")); 

print(dirname);

run("Set Measurements...", "integrated redirect=None decimal=3");

nom=newArray(nFichiers*5);
nucvol=newArray(nFichiers*5);

setBackgroundColor(0, 0, 0);

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
			//waitForUser;

		
		// ---- Open the roi
			roiManager("Open", dir+"res_"+nomeim+"_RoiSet.zip");
			nRoi=roiManager("count");	
		// ---- make image duplicates	named roi_1, roi_2...
			for (j = 0; j < nRoi; j++) 
			{
				selectWindow("wnucleus");
				roiManager("Deselect");
				roiManager("Select", j);
				
				run("Duplicate...", "title=roi_"+j+" duplicate");
				
				
				run("Make Inverse");

				run("Fill", "stack");
				//run("Clear Outside");
				run("Select None");
				rename("roi_"+j);
				
			}				
				roiManager("reset");
				
		  		selectWindow("wnucleus");
		  		close();	
				
		//print("0");  								
//------------------Measure volume----------	
			for (i = 0; i < nRoi; i++) 
			{
			selectWindow("roi_"+i);	
			run("Select None");
	
			//wait(1200);
			//run("Subtract...", "value=254 stack");
			//print("1");
			run("Z Project...", "projection=[Sum Slices]");
			setThreshold(1.0000, 1000000000000000000000000000000.0000);
		
			//print("2");
			run("Measure");
			//print("3");

	
				nom[k]=nomeim+"_roi_"+k;						
				nucvol[k]=getResult("IntDen", k)*0.0002;
						print(nucvol[k]);
						
						selectWindow("roi_"+i);
						close();
						
						//close();     //********
						//run("Close All");
							k=k+1;
							
			} // for ROI measure


		} // if image nucleus
	
} // if C h == 1
//print("4");
run("Close All");
}  //for fichier
//saveAs("Results", dir2+"Results_NucVol_"+nom[0]+"_to_"+nom[k-1]+"_.csv");
print("nombre de cellules : "+k);
print("\\Clear");


// --------------------- Tab results -------------------
Titre="[Nucleus_Size]";
run("New... ", "name="+Titre+" type=Table");


 			
 				header="Name"+"\t Nucleus_volume_(um3) \t Conditions \t";
 		
print(Titre, "\\Headings:"+header);




	for(j=0; j<k; j++)
	{
	//je remplis de nouvelles lignes à chaque nouvel échantillon
	//print("tb1");
 				
	Rez=nom[j]+"\t"+nucvol[j]+"\t"+dirname+"\t";
	//Rez=nom[j]+"\t"+pearson[j]+"\t"+m1[j]+"\t"+m2[j]+"\t"+centresAcoloc[j]+"\t"+centresA[j]+"\t"+centresBcoloc[j]+"\t"+centresB[j]+"\t"+lowA[j]+"\t"+lowB[j]+"\t"+colocvolumexy+"\t"+colocvolumez+"\t"+minlowA+"\t"+minlowB+"\t";
				
 			
                
    print(Titre, Rez) ;
	}
saveAs("Results", dir2+"NucVol_"+dirname+"_.csv");

//print(nom[0]+"_to_"+nom[k-1]);


