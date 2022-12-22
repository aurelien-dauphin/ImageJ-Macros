


dir=getDirectory("Choose a Directory with the objects in 2 colors, C2 and C3, for calculating the pearson coeficient");
dir2=getDirectory("Choose a Directory for results");
listeFichiers=getFileList(dir);
nFichiers=listeFichiers.length;


nom=newArray(nFichiers);
npart=newArray(nFichiers);

pearson=newArray(nFichiers);
k=0;

//							--------------------File loop----------------------
for (i = 0; i < nFichiers; i++)  {

if (startsWith(listeFichiers[i], "C2-")&&endsWith(listeFichiers[i], ".tif")) {
	open(dir+listeFichiers[i]);

nome=getTitle();

	
nomeim=substring(nome, 3);
nom[k]=nomeim;
rename("C2");
setThreshold(1, 65535, "raw");
run("Make Binary", "method=Default background=Dark");

open(dir+"C3-"+nomeim);
rename("C3");
setThreshold(1, 65535, "raw");
run("Make Binary", "method=Default background=Dark");
run("JACoP ", "imga=C2 imgb=C3 pearson");

log1=getInfo("log");
log1=substring(log1, lastIndexOf(log1, "r=")+2, lengthOf(log1));
//print(log1);
pearson[k]=log1;
//print("\\Clear");
close();
close();
	k=k+1;
}


}


Titre="[Bilan_Pearson]";
run("New... ", "name="+Titre+" type=Table");


 			
 				header="Nom"+"\t Pearson";
 		
print(Titre, "\\Headings:"+header);



//print("max data = "+max+"\t nfichiers ="+nFichiers);


for(j=0; j<k; j++)
{
//je remplis de nouvelles lignes à chaque nouvel échantillon
	
 				
					Rez=nom[j]+"\t"+pearson[j]+"\t";
				
 			
                
                print(Titre, Rez) ;
}
saveAs("Results", dir2+nom[0]+"etal_Batch_Pearson.csv");
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


