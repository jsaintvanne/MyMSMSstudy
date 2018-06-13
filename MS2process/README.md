# MS2process package

This package has been develloped in R language, by Alexis Delabriere (https://github.com/adelabriere) during his thesis.
The package has not been published yet, but some old scripts are disponible on his github.


***
## Study
There is no publication for this package.
The workflow to obtain MGF files of mapping MSMS spectra is the following :

![Workflow MS2process](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MS2process/Workflow%20for%20MSMS%20-%20MS2process.jpg?raw=true)

I didn't look at the other parts of the package yet. There are formula generation for MSMS spectra, Sirius tree generation and probably some else tools also.


***
## Issues

Some problems appeared during the testing time on this package.

### Installation of the package
#### Problem

I have the package in the format `.tar.gz`. I can install it with the following command :
```
 R CMD INSTALL MS2Process.tar.gz
```
So, now the package is install with the `tar.gz` file. But I can't find the scripts in my library. I find the package installed but there is no scripts R in its repository.

#### Solution

To facing that, I have to source the different R scripts before running them each time I modify something. To do this I found a little function that allow me to source evry MS2Process scripts in one time :
```R
sourceDir<-function(path,trace=TRUE,...){
  print("MS2-classes.R :\n")
  #this R script contains all classes and need to be source at first
  source("./repopath/MS2-classes.R")
  #then we can source each file one by one
  for (nm in list.files(path, pattern = "[.][RrSsQq]$")) {
    if(trace) cat(nm,":\n")
	    source(file.path(path, nm), ...)
  }
}
#Now, we can source our R scripts in our repo each time we have done some modifications
sourceDir("./repopath/")
```
It could be better to rebuild the package each time and reload it in R after that...?

### About the peak 166.08 of file `STD_MIX1`
#### Problem

We are looking for a compound with a m/Z at 166.086 find as the L-phenylalanine in the result file. To start this study, we can observe on the TIC chromatogram a peak with this mass and around 500 seconds of retention time. The problem is that this peak isn't find when we process MS2Process on our file `STD_MIX1`.
We have to find where we lost this peak which should map correctly... So, we have it in `xraw@msnPrecursorMz` (as MS2 with RT = 501 and 519)
```R
> xraw@msnPrecursorMz[grep("^166.08",xraw@msnPrecursorMz,ignore.case=FALSE)]
[1] 166.0863 166.0863
> xraw@msnRt[grep("^166.08",xraw@msnPrecursorMz,ignore.case=FALSE)]
[1] 501.0598 519.4885
> xraw@msnPrecursorIntensity[grep("^166.08",xraw@msnPrecursorMz,ignore.case=FALSE)]
[1] 13453806 6129614
```
Then in `mpeaks@.Data` (as MS1)
```R
> mpeaks@.Data[grep("^166.08",mpeaks@.Data[,"mz"],ignore.case=FALSE),]
      mz    mzmin    mzmax       rt    rtmin    rtmax
166.0863 166.0862 166.0863 508.6326 500.9193 516.5077
        into         intb         maxo   sn
1.118349e+09 1.117974e+09 1.230181e+08 5599
```
So, here we can easily match the first precursor with the MS peak. But when we run `MSMSacquisition` we can only obtain this `macq@mspeaks@.Data` (as MS1)
```R
> macq@mspeaks@.Data[grep("^166.08",macq@mspeaks@.Data[,"mz"],ignore.case=FALSE),]
      mz    mzmin    mzmax       rt    rtmin    rtmax
166.0863 166.0862 166.0863 508.6326 500.9193 516.5077
        into         intb         maxo   sn
1.118349e+09 1.117974e+09 1.230181e+08 5599
```
And this in `macq@header` (as MS2 which match on MS)...
```R
> macq@header[grep("^166.08",macq@header[,"mz"],ignore.case=FALSE),]
[1] mz            mspeak        nspec         maxMSMSsignal rt           
[6] group         energy       
<0 lignes> (ou 'row.names' de longueur nulle)
```
For the first precursor it is between the range of this MS peak so it is strange that it doesn't map. For the second one, it is out of the range of the MS peak, it is quite more normal that it doesn't map. So why this precursor doesn't match with the MS peak ? The problem looks to be during the rawEIC function :
 ```R
      precMz  precInt precScan collisionEnergy msLevel   bmin   bmax precTime
919 166.0863 13453806      185              60       2 567122 567687 500.9193
[1] "Num scan cscan msms"
[1] 185
[1] "Function rawEIC"
$scan
[1] 184 185 186
$intensity
[1] 0 0 0
 ```
We can see here that the intensity is null for scans 184, 185 and 186. I don't know how and where these intensities are found... I'm searching for them !

#### Solution

After contacting Alexis Delabrière, it is possible to pass out the restriction on differents peaks. Just passing the argument `fwhsym` to FALSE (or 0) to find our precursor matching on the MS2 peak.
```R
> macq <- MSMSacquisition(xraw,tolMS=0.01,peaklist = mpeaks, fwhmsym = 0.0)
> macq@header[grep("^166.08",macq@header[,"mz"],ignore.case=FALSE),]
          mz mspeak nspec maxMSMSsignal       rt group energy
323 166.0863   1296     2       2902644 508.6326   323     60
```
So, now, the first precursor match correctly on the MS peak. Only the second precursor don't match. It is quite normal cause his RT is not between the RT range of the MS peak. To try to correct a little that, maybe it is possible to introduce a variable name `tolRT` which can tolerate a little deviation of the RT range of the MS peak trying to match with the maximum of precursors.

***
## Development
I would like to access the R scripts of the package to be able to modify them and try to find why it can't work. (problem 1)  
To face the problem 1, I can source each R scripts each time I modified one of them and run again the workflow manually on R. I can do it with a new function name `sourceDir` whith which I can source all scripts in my directory.
