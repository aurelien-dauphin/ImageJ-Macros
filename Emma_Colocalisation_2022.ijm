/*
 * Get the images registered "res_..._ch1.tif"
 * Get the ROI after usig Emma_ROI macro, in "res_..._RoiSet.zip"
 * 
 * Crop the ROI, clean outside
 * Use Jacop plugin to get Pearson, Manders Object based 
 * 
 * Make a tab results and save it
 * 
 */

chA=2;
chB=3;
colocvolumexy=120;
colocvolumez=300;

dir=getDirectory("Choose a Directory with the objects in 2 colors, as in _ch2.tif, and _ch_3.tif, for calculating the pearson and Manders coeficient");
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

//							--------------------File loop----------------------
for (i = 0; i < nFichiers; i++)  {

if (endsWith(listeFichiers[i], "_ch_"+chA+".tif")) {
	open(dir+listeFichiers[i]);

nome=getTitle();

nomeim=substring(nome, 4 , nome.length-9);
nom[k]=nomeim;


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


