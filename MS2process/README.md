# MS2process package

This package has been develloped in R language, by Alexis Delabriere (https://github.com/adelabriere) during his thesis.
The package has not been published yet, but some old scripts are disponible on his github.


***
## Study
There is no publication for this package.
The workflow to obtain MGF files of mapping spectra MSMS is the following :

![Workflow MS2process](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MS2process/Workflow%20for%20MSMS%20-%20MS2process.jpg?raw=true)

I didn't look at the other parts of the package yet. There are formula generation for MSMS spectra, Sirius tree generation and probably some else tools also.


***
## Problems

Some problems appeared during the testing time on this package :

1. when the package is installed with the tar.gz file, I can't find the scripts in my library. I find the package install but there is no scripts R in its repository. SOLUTION : have to source the different R scripts before running them each time I modify something.

2. I can still run the workflow with my testing files and the test files of Alexis. I obtain the MGF files however they don't contain any peaklist. I have just the different informations about the MSMS spectra but no peaklist.

3. We can see a good peak on m/z = 166.08 with 500 < RT < 516 but this peak is not conserved for the next step (MSMSacquisition). We have to find where we lost this peak which should map correctly... We have it in `xraw@msnPrecursorMz` (as MS2 with RT = 501 and 519), then in `mpeaks@.Data` (as MS1), then in `macq@mspeaks@.Data` (as MS1), but we can't find it in `macq@header` (as MS2)... For the first one it is between the range of this peak so it is strange that it doesn't map. For the second one, it is out of the range of the peak, it is quite more normal that it doesn't map.


***
## Development
I would like to access the R scripts of the package to be able to modify them and try to find why it can't work. (problem 1)  
To face the problem 1, I can source each R scripts each time I modified one of them and run again the workflow manually on R. I can do it with a new function name `sourceDir` whith which I can source all scripts in my directory.
