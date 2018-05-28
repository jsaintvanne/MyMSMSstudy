# MS2process package

This package has been develloped in R language, by Alexis Delabriere (https://github.com/adelabriere) during his thesis.
The package has not been published yet, but some old scripts are disponible on his github.

***
## Study
There is no publication for this package.
The workflow to obtain MGF files of mapping spectra MSMS is the following :

![Workflow MS2process](lien image workflow?raw=true)

I don't look at the other parts of the package yet. There are formula generation for MSMS spectra, Sirius tree generation and probably some else tools also.

***
## Problems
Some problems appeared during the testing time on this package :
1. when the package is installed with the tar.gz file, I can't find the scripts in my library. I find the package install but there is no scripts R in its repository  

2. I can still run the workflow with my testing files and the test files of Alexis. I obtain the MGF files however they don't contain any peaklist. I have just the different informations about the MSMS spectra but no peaklist.

***
## Development
I would like to access the R scripts of the package to be able to modify them and try to find why it can't work. (problem 1)
