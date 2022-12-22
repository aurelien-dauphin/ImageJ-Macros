/*
 * Get the images registered "res_..._ch1.tif" ch_2 and ch_3.tif
 * Get the ROI in the same folder, after usig Emma_ROI macro, in "res_..._RoiSet.zip"
 * Get the mask with the nucleux in the same folder, using the macro Emma_Nucleus_Mask_2023
 * Make composite of 2 channels
 * Crop the ROI, clean outside
 * Use Jacop plugin to get Pearson, Manders and Object based 
 * 
 * Make a tab results and save it
 * 
 */
 
 
chN=1; //1 only if you made mask with the nucleux with the macro Emma_Nucleus_Mask_2023. 
chA=2;
chB=3;
colocvolumexy=0.120;
colocvolumez=0.300;

dir=getDirectory("Choose a Directory with the objects in 2 colors, as in _ch_2.tif, and _ch_3.tif, for calculating the pearson and Manders coeficient");
dir2=getDirectory("Choose a Directory for results");
listeFichiers=getFileList(dir);
nFichiers=listeFichiers.length;


nom=newArray(nFichiers);
npart=newArray(nFichiers);

pearson=newArray(nFichiers);
m1=newArray(nFichiers);
m2=newArray(nFichiers);
centresAcoloc=newArray(nFichiers);
centresBcoloc=newArray(nFichiers);
centresA=newArray(nFichiers);
centresB=newArray(nFichiers);

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
			print("########################### I open the nucleus : "+l+" / "+ round(nFichiers/3)+" of "+nomeim);
			rename("wnucleus");
		//---open the 2 colors	
			open(dir+"res_"+nomeim+"_ch_2.tif");
			rename("wch2_raw");
			imageCalculator("Multiply create stack", "wch2_raw", "wnucleus");
				//rename(nomidquant+"_Wch"+Chquant);
			rename("wch2");
			open(dir+"res_"+nomeim+"_ch_3.tif");
			rename("wch3_raw");
			imageCalculator("Multiply create stack", "wch3_raw", "wnucleus");
			rename("wch3");
			
		// ---- make the composite
		  	run("Merge Channels...", "c1=wch2 c2=wch3 create");
		  	selectWindow("wnucleus");
		  	close();
		// ---- Open the roi
			roiManager("Open", dir+"res_"+nomeim+"_RoiSet.zip");
			nRoi=roiManager("count");	
		// ---- make duplicates	named Nucroi1, Nucroi2...
			for (j = 0; j < nRoi; j++) 
			{
				roiManager("Deselect");
				roiManager("Select", j);
				
				run("Duplicate...", "title=roi_"+j+" duplicate");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
				run("Select None");
				rename("roi_"+j);
				
			}				
				roiManager("reset");
				selectWindow("wch3_raw");
		  		close();	
		  		selectWindow("Composite");
		  		close();	
		  		
				selectWindow("wch2_raw");
		  		close();	
		  								
//------------------( Call Function )to assess colocalisation i----------	
			for (i = 0; i < nRoi; i++) 
			{
			selectWindow("roi_"+i);	
			run("Select None");
			run("Split Channels");
			//rename("CB");
			setAutoThreshold("Moments dark stack");
			waitForUser("C2-roi_"+i, "How is the threshold of ch_2 ?");	
			getThreshold(lowerB, upperB);
			
			selectWindow("C1-roi_"+i);
			setAutoThreshold("Moments dark stack");
			waitForUser("C1-roi_"+i, "How is the threshold of ch_1 ?");	
			getThreshold(lowerA, upperA);
			
			run("JACoP ", "imga=C1-roi_"+i+" imgb=C2-roi_"+i+" thra="+lowerA+" thrb="+lowerB+" pearson mm objdist=3-2129400-"+colocvolumexy+"-"+colocvolumez+"-true-true-true");
		log1=getInfo("log");
		log2=substring(log1, lastIndexOf(log1, "r=")+2, lastIndexOf(log1, "Manders' Coefficients (original):")-2);
				log3=substring(log1, lastIndexOf(log1, "M1=")+3, lastIndexOf(log1, "M2=")-31);
						log4=substring(log1, lastIndexOf(log1, "M2=")+3, lastIndexOf(log1, "Colocalization")-32);
								logA=substring(log1, lastIndexOf(log1, "A:")+3, lastIndexOf(log1, "B:")-6);
								log5=substring(logA, 0, lastIndexOf(logA, "centre")-1);
								log6=substring(logA, lastIndexOf(logA, "of")+3, lengthOf(logA)-1);
								logB=substring(log1, lastIndexOf(log1, "B:")+3, lengthOf(log1));
								log7=substring(logB, 0, lastIndexOf(logB, "centre")-1);
								log8=substring(logB, lastIndexOf(logB, "of")+3, lengthOf(logB)-1);
					//print(log1);
					print(" logged ");
					print(log2+"#"+log3+"#"+log4+"#"+log5+"#"+log6+"#"+log7+"#"+log8);			
		nom[k]=nomeim+"_roi_"+i;						
		pearson[k]=log2;
		m1[k]=log3;
		m2[k]=log4;
		centresAcoloc[k]=log5;
		centresBcoloc[k]=log7;
		centresA[k]=log6;
		centresB[k]=log8;
		
		selectWindow("Distance based colocalization between C1-roi_"+i+" and C2-roi_"+i+" (centres of mass)");
		saveAs("Results", dir2+nom[k]+"_Distance_based_coloc_(centres of mass).csv");
		waitForUser("IL VA FAIRE TOUT NOIR "+nom[k]);
						
						
						print("\\Clear");
						//print("\\Clear");
						selectWindow("C1-roi_"+i);
						close();
						selectWindow("C2-roi_"+i);
						close();
						close();
						//run("Close All");
							k=k+1;
							
			}


		}
	
}
}

// --------------------- Tab results -------------------
Titre="[Bilan_Colocalization]";
run("New... ", "name="+Titre+" type=Table");


 			
 				header="Name"+"\t Pearson \t M1 \t M2 \t CentresAColoc \t CentresA \t CentresBColoc \t CentresB";
 		
print(Titre, "\\Headings:"+header);



//print("max data = "+max+"\t nfichiers ="+nFichiers);


	for(j=0; j<k; j++)
	{
	//je remplis de nouvelles lignes à chaque nouvel échantillon
	
 				
	Rez=nom[j]+"\t"+pearson[j]+"\t"+m1[j]+"\t"+m2[j]+"\t"+centresAcoloc[j]+"\t"+centresA[j]+"\t"+centresBcoloc[j]+"\t"+centresB[j]+"\t";
				
 			
                
    print(Titre, Rez) ;
	}
saveAs("Results", dir2+nom[0]+"etal_Batch_Coloc.csv");
selectWindow("Log");
saveAs("Text", dir2+nom[0]+"etal_Batch_Log.txt");
print("The end");		
			
				
																	
		

/*
rename("CA");
setAutoThreshold("Moments dark stack");
waitForUser("CA", "How is the threshold ?");	
getThreshold(lowerA, upperA);

open(dir+"res_"+nomeim+"_ch_"+chB+".tif");

rename("CB");

setAutoThreshold("Moments dark stack");
waitForUser("CB", "How is the threshold ?");	
getThreshold(lowerB, upperB);
//Get the ROI after usig Emma_ROI macro, in "res_..._RoiSet.zip"

open(dir+"res_"+nomeim+"_RoiSet.zip");

		for (j = 0; j < roiManager("count"); j++) {
		selectWindow("CA");
		roiManager("deselect");
		roiManager("select", j);
		run("Duplicate...", "title=CA_"+j+1+" duplicate");
		selectWindow("CB");
		roiManager("select", j);
		run("Duplicate...", "title=CB_"+j+1+" duplicate");
		
		
		run("JACoP ", "imga=CA_"+j+1+" imgb=CB_"+j+1+" thra="+lowerA+" thrb="+lowerB+" pearson mm objdist=3-2129400-"+colocvolumexy+"-"+colocvolumez+"-true-true-true");
		log1=getInfo("log");
		log2=substring(log1, lastIndexOf(log1, "r=")+2, lastIndexOf(log1, "r=")+7);
				log3=substring(log1, lastIndexOf(log1, "M1=")+3, lastIndexOf(log1, "M1=")+8);
						log4=substring(log1, lastIndexOf(log1, "M2=")+3, lastIndexOf(log1, "M2=")+8);
								logA=substring(log1, lastIndexOf(log1, "A:")+3, lastIndexOf(log1, "B:")-6);
								log5=substring(logA, 0, lastIndexOf(logA, "centre"));
								log6=substring(logA, lastIndexOf(logA, "of")+3, lengthOf(logA));
								logB=substring(log1, lastIndexOf(log1, "B:")+3, lengthOf(log1));
								log7=substring(logB, 0, lastIndexOf(logA, "centre"));
								log8=substring(logB, lastIndexOf(logA, "of")+3, lengthOf(logA));
					//print(log1);
					//print(log2, log3, log4, log5, log6, log7, log8);			
								
		pearson[k]=log2;
		m1[k]=log3;
		m2[k]=log4;
		centresAcoloc[k]=log5;
		centresBcoloc[k]=log7;
		centresA[k]=log6;
		centresB[k]=log8;
		waitForUser("IL VA FAIRE TOUT NOIR");
						//print("\\Clear");
						close();
						close();
						run("Close All");
							k=k+1;
													}


}
}

Titre="[Bilan_Colocalization]";
run("New... ", "name="+Titre+" type=Table");


 			
 				header="Name"+"\t Pearson \t M1 \t M2 \t CentresAColoc \t CentresA \t CentresBColoc \t CentresB";
 		
print(Titre, "\\Headings:"+header);



//print("max data = "+max+"\t nfichiers ="+nFichiers);


for(j=0; j<k; j++)
{
//je remplis de nouvelles lignes à chaque nouvel échantillon
	
 				
					Rez=nom[j]+"\t"+pearson[j]+"\t"+m1[j]+"\t"+m2[j]+"\t"+centresAcoloc[j]+"\t"+centresA[j]+"\t"+centresBcoloc[j]+"\t"+centresB[k]+"\t";
				
 			
                
                print(Titre, Rez) ;
}
saveAs("Results", dir2+nom[0]+"etal_Batch_Coloc.csv");
selectWindow("Log");
saveAs("Text", dir2+nom[0]+"etal_Batch_Log.txt");
print("The end");
/*
 * 
 selectWindow("C2");
setThreshold(1, 65535, "raw");
run("Make Binary", "method=Default background=Dark");
selectWindow("C3");
setThreshold(1, 65535, "raw");
run("Make Binary", "method=Default background=Dark");
run("JACoP ", "imga=C2 imgb=C3 thra=1 thrb=1 pearson mm");

*/


