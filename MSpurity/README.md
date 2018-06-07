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

- About the peak 166.08 of `STD_MIX1`:

  - with `readMSData` we can find 2 MS2 spectra with a precursorMZ of 166.08 and a precursorRT around 510 seconds. There is no MS1 spectra with a peak at 166.08 cause the peakpicking is not done yet (raw_data@featureData@data column precursorMZ).
  ```R
  > raw_data@featureData@data[grep("^166.08",raw_data@featureData@data[grep("^2",raw_data@featureData@data[,"msLevel"],ignore.case=FALSE),"precursorMZ"],ignore.case=FALSE),]
             fileIdx spIdx centroided smoothed seqNum acquisitionNum msLevel
  F1.S0919       1   919         NA       NA    919           1832       2
  F1.S0954       1   954         NA       NA    954           1903       2
             polarity originalPeaksCount totIonCurrent retentionTime basePeakMZ
  F1.S0919        1                468     2915821.8      419.4003   64.92744
  F1.S0954        1                198      243644.9      435.1370   83.06045
             basePeakIntensity collisionEnergy ionisationEnergy    lowMZ   highMZ
  F1.S0919         1410801.4              60                0 49.50187 171.7143
  F1.S0954          225494.2              60                0 49.50196 106.0574
             precursorScanNum precursorMZ precursorCharge precursorIntensity
  F1.S0919             1830   147.06520               0            5224680
  F1.S0954             1902    83.06041               1            1478174
             mergedScan mergedResultScanNum mergedResultStartScanNum
  F1.S0919          0                   0                        0
  F1.S0954          0                   0                        0
             mergedResultEndScanNum injectionTime
  F1.S0919                      0    0.04331523
  F1.S0954                      0    0.08843617
                                                spectrumId spectrum
  F1.S0919 controllerType=0 controllerNumber=1 scan=1832      919
  F1.S0954 controllerType=0 controllerNumber=1 scan=1903      954
  > raw_data@featureData@data[grep("^166.08",raw_data@featureData@data[grep("^1",raw_data@featureData@data[,"msLevel"],ignore.case=FALSE),"basePeakMZ"],ignore.case=FALSE),]
  [1] fileIdx                   spIdx                 centroided
  [4] smoothed                  seqNum                acquisitionNum
  [7] msLevel                   polarity              originalPeaksCount
  [10] totIonCurrent            retentionTime         basePeakMZ
  [13] basePeakIntensity        collisionEnergy       ionisationEnergy
  [16] lowMZ                    highMZ                precursorScanNum
  [19] precursorMZ              precursorCharge       precursorIntensity
  [22] mergedScan               mergedResultScanNum   mergedResultStartScanNum
  [25] mergedResultEndScanNum   injectionTime         spectrumId
  [28] spectrum
  <0 lignes> (ou 'row.names' de longueur nulle)
  ```

  - with `findChromPeaks` I can find only one peak MS1 with 166.08 as MZ and a RT around 509 (xdata@msFeatureData$chromPeaks line 2313).
  ```R
   > xdata@msFeatureData@.xData$chromPeaks[grep("^166.08",xdata@msFeatureData@.xData$chromPeaks[,"mz"],ignore.case=FALSE),]
              mz        mzmin        mzmax       rt    rtmin      rtmax
        166.0863     166.0862     166.0867 508.6326 490.5224   529.6350
            into         intb         maxo       sn   sample  is_filled
1.172816e+09 1.171865e+09 1.230181e+08     5984        1          0
  ```

  - with `xcms-group` we can generate directly a peaklist on Galaxy. So, I can find peaks with MZ = 166.08 and RT around 511 seconds.
  ```R
  name	     namecustom	    mz	             mzmin	          mzmax
  "M166T511"   "M166_0863T511"   166.086266751926   166.053513151908   166.14401815256
  rt	       rtmin	   rtmax	    npeaks  .	peakidx
  511.395444   508.63257   579.291096   3       1    c(1471, 1669, 2313)
  ```

  - with `assess-purity` I can also find peaks with MZ = 166.08 (lines 954 and 919 on tsv file). However, their RT is around 1000 seconds... How is it possible whereas we saw 2 MS2 spectra with precursorMZ at 166.08 and precursorRT around 500 ??
  ```R
  > pa@puritydf[grep("^166.08",pa@puritydf[,"precursorMZ"],ignore.case=FALSE),]
        pid fileid seqNum precursorIntensity precursorMZ precursorRT
919 919      1   1104           13453806    166.0863    978.9494
954 954      1   1146            6129614    166.0863   1015.6266
        precursorScanNum   id        filename precursorNearest seqNum      aMz
919             2202 1104 dataset_831.dat             1103   1104 166.0863
954             2286 1146 dataset_831.dat             1145   1146 166.0867
        aPurity apkNm      iMz iPurity ipkNm inPkNm inPurity
919       1     1 166.0863       1     1      1        1
954       1     1 166.0867       1     1      1        1
  ```

  - So it is an evidence that after the mapping with `frag4feature` I can't find these peaks !


***
## Development
Galaxy has been reproducted in local to be able to make some modifications on the script.
