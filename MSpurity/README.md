# MSpurity package

This package has been developed by a team of Birmingham. The maintainer is Thomas Lawson (https://github.com/Tomnl) from the School of Biosciences in the University of Birmingham (UK).


***
## Study
This Birmingham team published on its tool (https://pubs.acs.org/doi/abs/10.1021/acs.analchem.6b04358).
The workflow is the following :

![Workflow msPurity](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MSpurity/Workflow%20for%20MSMS%20-%20Birmingham%20msPurity.jpg?raw=true)

1. Some preparation are needed for msPurity :
  - The input for the msPurity R package requires the raw vendor format of the mass spectrometry data to be converted into the mzML file format.
  - If spectra were not collected in centroid mode, it is essential that the peaks are converted from profile to centroid format before processing within msPurity.

2. After that, some treatments allow to obtain a filtering peaklist (MS2??) :
  - filtering out peaks below a user determined signal-to-noise level
  - averaging between multiple scans
  - filtering peaks not present in a minimum number of scans
  - filtering of peaks where the relative standard deviation of the intensity is below a given threshold
  - removing blank peaks from the sample peak list

3. The median precursor purity score can now be determine for each feature accross all scans.

4. The isotopic peak <sup>13</sup>C of the targeted precursor can be remove (isotopes option of purityA function).

5. We can have a lot of peaks with low intensity in our scan. This step remove all peaks that have less than 5% intensity of the targeted precursor ion peak for the precursor purity calculation (ilim option of purityA function).

6. We now have the spectra of MSMS with their precursor purity score in a part. And at the other part, we process xcms tools to obtain a peaklist of MS chromatographic spectra. We have to map the precursor on the MS peaks to continue with the good MSMS spectra. It is the function frag4feature that can do it.


***
## Problems
I'm trying to use this package on a local Galaxy. It looks that works but some problems persist :
- the famous pic 166.08 (`STD_MIX1_POS`) is in the raw_data object after `readMSData` function, as a MS2 precursorMZ. It is lost in the following steps for MS1 peaks cause it is not present as MS1 peak. That is strange. And that is why it can't be map in the next step (`frag4feature`).

***
## Development
Galaxy has been reproducted in local to be able to make some modifications on the script.
