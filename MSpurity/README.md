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
## Issues
I'm trying to use this package on a local Galaxy. It looks that works but some problems persist :

### About the peak 166.08 of file `STD_MIX1`
<details><summary>
Let me see this problem
</summary>

#### Problem

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
```
```R
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
  name	     namecustom	       mz	           mzmin	      mzmax
  "M166T511"   "M166_0863T511"   166.086266751926   166.053513151908   166.14401815256
  rt	     rtmin	 rtmax	        npeaks   .	   peakidx
  511.395444   508.63257   579.291096     3       1    c(1471, 1669, 2313)
```
- with `assess-purity` I can also find peaks with MZ = 166.08 (lines 954 and 919 on tsv file). However, their RT are around 1000 seconds... How is it possible whereas we saw 2 MS2 spectra with precursorMZ at 166.08 and precursorRT around 500 ??
```R
> pa@puritydf[grep("^166.08",pa@puritydf[,"precursorMZ"],ignore.case=FALSE),]
      pid fileid seqNum precursorIntensity precursorMZ precursorRT
  919 919      1   1104           13453806    166.0863    978.9494
  954 954      1   1146            6129614    166.0863   1015.6266
      precursorScanNum   id          filename precursorNearest seqNum      aMz
  919             2202 1104 "dataset_831.dat"             1103   1104 166.0863
  954             2286 1146 "dataset_831.dat"             1145   1146 166.0867
      aPurity apkNm       iMz iPurity ipkNm inPkNm inPurity
  919       1     1  166.0863       1     1      1        1
  954       1     1  166.0867       1     1      1        1
```
- So it is an evidence that after the mapping with `frag4feature` I can't find these peaks !

#### Solution

Thomas Lawson has corrected his scripts to be able to run a dataset containing switch between positive and negative scans (like my dataset). So, now, with the function `assess-purity` on Galaxy, we obtain the precursor 166.08 and their good RT.
```R
> pa@puritydf[grep("^166.08",pa@puritydf[,"precursorMZ"],ignore.case=FALSE),]
    pid fileid seqNum acquisitionNum precursorIntensity precursorMZ precursorRT
919 919      1   1104           2203           13453806    166.0863    500.9193
954 954      1   1146           2287            6129614    166.0863    519.3483
    precursorScanNum   id        filename precursorNearest seqNum      aMz
919             2202 1104 dataset_831.dat             1103   1104 166.0863
954             2286 1146 dataset_831.dat             1145   1146 166.0867
    aPurity apkNm      iMz iPurity ipkNm inPkNm inPurity
919       1     1 166.0863       1     1      1        1
954       1     1 166.0867       1     1      1        1
```
Now, we can try to match these precursors with the MS peaks found after the function `findChromPeaks`.
```R
> xdata@msFeatureData@.xData$chromPeaks[grep("^166.08",xdata@msFeatureData@.xData$chromPeaks[,"mz"],ignore.case=FALSE),]
              mz        mzmin        mzmax       rt    rtmin      rtmax
        166.0863     166.0862     166.0867 508.6326 490.5224   529.6350
          into         intb         maxo       sn   sample  is_filled
  1.172816e+09 1.171865e+09 1.230181e+08     5984        1          0
```
To do this, we use the function `frag4feature` on our local Galaxy. This function will match the precursor of MSMS scans with the MS peaks we can found. When we verify if our precursors 166.08 matched, we obtain :
```R
> pa@grped_df[grep("^166.08",pa@grped_df[,"precurMtchMZ"],ignore.case=FALSE),]
   grpid       mz    mzmin    mzmax       rt    rtmin   rtmax       into
41   378 166.0863 166.0862 166.0867 508.6326 490.5224 529.635 1172815917
67   378 166.0863 166.0862 166.0867 508.6326 490.5224 529.635 1172815917
         intb      maxo   sn sample is_filled  cid        filename precurMtchID
41 1171865158 123018056 5984      1         0 2313 dataset_831.dat         1104
67 1171865158 123018056 5984      1         0 2313 dataset_831.dat         1146
   precurMtchRT precurMtchMZ precurMtchPPM inPurity pid
41     500.9193     166.0863      0.222529        1 919
67     519.3483     166.0867      2.611218        1 954
```
We can see that for the same MS peak, our two precursors matches. So, now, we can process the `create-msp` function on Galaxy. Then run it with MetFrag, Sirius or another one for which Thomas Lawson developed a script. We obtain these informations on the `msp` file for our precursors :
```
NAME: 378-1-919
PRECURSORMZ: 166.086303710938
Comment:
Num Peaks: 566
49.5019264221191	0
49.5020904541016	0
49.5022583007812	0
49.5024223327637	0
51.022144317627	0
51.0223197937012	0
...

NAME: 378-1-954
PRECURSORMZ: 166.086700439453
Comment:
Num Peaks: 535
49.5020446777344	0
49.5022087097168	0
49.5023765563965	0
49.5025405883789	0
51.0222663879395	0
51.0224418640137	0
...
```
The name correspond to the group, then the id of the sample (here we have only one sample) and the last one is the id of the precursor. But we can see that it stays a lot of peaks in the peaklist. Some of them have an intensity equal to 0. That's because we don't have a centroided spectra for MSMS. Just to correct it and we obtain better centroided peaklist :
```
NAME: 378-1-919
PRECURSORMZ: 166.086303710938
Comment:
Num Peaks: 36
51.0233726501465	10033.8544921875
52.5113182067871	4487.92822265625
53.0389823913574	140671.640625
54.3064384460449	4468.5771484375
55.0182952880859	6673.57666015625
57.538257598877	4193.35400390625
62.2816581726074	4215.7041015625
64.1604690551758	4182.18115234375
77.0386123657227	5983.353515625
79.0542526245117	125339.03125
79.953727722168	4489.4130859375
81.0334625244141	5761.34912109375
83.0470962524414	4337.9619140625
83.8272323608398	4109.48486328125
85.0841598510742	5722.2822265625
91.0514221191406	6566.38134765625
91.0542678833008	147917.328125
93.069938659668	164891.859375
94.0651321411133	7676.0380859375
95.0490570068359	29895.056640625
102.046348571777	7902.32763671875
103.054267883301	1168881.5
105.044944763184	5865.373046875
107.04923248291	47210.75390625
111.399383544922	5355.50146484375
118.06510925293	23850.703125
119.073036193848	6831.6796875
120.047065734863	8689.994140625
120.080833435059	3020628
120.11678314209	7942.1796875
120.424011230469	4451.44677734375
129.787353515625	4737.8232421875
131.049240112305	68024.015625
141.702239990234	6725.1083984375
149.059692382812	32502.798828125
166.086486816406	73009.828125

NAME: 378-1-954
PRECURSORMZ: 166.086700439453
Comment:
Num Peaks: 36
51.0233917236328	6741.9501953125
53.0390968322754	77324.546875
53.7679443359375	3717.92700195312
58.4125289916992	3579.59790039062
66.454719543457	3991.7216796875
68.4431838989258	3341.18359375
76.6948165893555	3737.41870117188
78.2853469848633	3925.33911132812
79.0544052124023	69999.6484375
79.4851837158203	3818.17456054688
80.6856307983398	4134.36328125
81.0337753295898	5973.25927734375
90.5808639526367	4085.689453125
91.0544967651367	79321.0078125
91.5904083251953	3860.263671875
93.0701446533203	63780.41796875
93.8321990966797	3826.61352539062
94.5724716186523	4006.57592773438
95.0494384765625	16292.794921875
102.046585083008	5644.57763671875
103.054489135742	537894.4375
105.045036315918	4136.20458984375
107.049324035645	30756.51953125
118.065391540527	7710.060546875
118.086082458496	4536.40673828125
119.07300567627	6354.59033203125
120.081092834473	1543519.625
121.44596862793	4736.69140625
124.087501525879	4494.10546875
131.049499511719	29412.689453125
131.912948608398	4248.62109375
149.060119628906	5933.87109375
152.073486328125	4242.849609375
157.379318237305	3980.82543945312
166.086761474609	41677.33984375
166.098419189453	4651.181640625
```
Now, we can process directly on Galaxy to obtain the results. We also can select the interesting peak like just before and send it on the MetFrag website to analyse it.

</p>

</details>

***
## Development
After contacting Thomas, we are convinced that some changes have to be made on msPurity and their Galaxy wrappers.
The first change concern the inputs. Thomas just needed files containing MS and MS/MS in the same file and can run the tool with them. But a lot of chimists can't do that. They start with a MS run then they run a second one for MS/MS. So they obtain 2 files : one with MS datas and one else with MS/MS data. I'm developping and improving the script to be able to have these different files as inputs.

I will present each possibility and then testing them with different datasets. For each test, XCMS parameters will be the following :

```R
> paramFindChromPeaks
Object of class:  CentWaveParam
Parameters:
 ppm: 25
 peakwidth: 5, 50
 snthresh: 10
 prefilter: 3, 100
 mzCenterFun: wMean
 integrate: 1
 mzdiff: -0.001
 fitgauss: FALSE
 noise: 0
 verboseColumns: FALSE
 roiList length: 0
 firstBaselineCheck TRUE
 roiScales length: 0
 > paramGroupChromPeaks
 Object of class:  PeakDensityParam
 Parameters:
  sampleGroups: numeric of length 1
  bw: 30
  minFraction: 0.5
  minSamples: 1
  binSize: 0.25
  maxFeatures: 50
```

#### For files containing MS and MS/MS
This case of input has already been developed by Thomas Lawson and is available in msPurity R package. I don't modify anything on it and after my modifications on multiple inputs it should always works well.

<details><summary>Development and testing</summary>

##### Development

![Graph files MSandMSMS](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MSpurity/graph_file_MSandMSMS.jpg?raw=true)

Here is the workflow for files containing MS and MS/MS in the same files. We can process it file by file, or run it with a lot of files also. We will retrieve the precursors easily because msConvert already prepare them when they are in the same file. We already have these informations and we can't mix MS/MS and their precursor between files because they are all in the same file.

##### Testing

###### STD_MIX 1
Test with `STD_MIX1` solo :

```R
> filepathsMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa<-purityA(filepathsMS2)
...
...
> nrow(pa@puritydf)
[1] 4894
> pa@fileListMS1
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileListMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileMatch
                                                         MS1
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
                                                         MS2
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 121.8-1435 seconds (2-23.9 minutes)
Mass range: 78.0343-381.337 m/z
Peaks: 78 (about 78 per sample)
Peak Groups: 57
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 6017
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.187 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset)
...
...
> paf4f@f4f_link_type
[1] "individual"
> nrow(paf4f@grped_df)
[1] 36
> paf4f@fileMatch
                                                         MS1
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
                                                         MS2
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
```

###### STD_MIX 1, STD_MIX 2 and STD_MIX 3
Test with `STD_MIX1`, `STD_MIX2` and `STD_MIX3` :

```R
> filepathsMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa<-purityA(filepathsMS2)
...
...
> nrow(pa@puritydf)
[1] 14828
> pa@fileListMS1
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileListMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileMatch
                                                         MS1
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
2 ./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML
3 ./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML
                                                         MS2
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
2 ./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML
3 ./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 3 samples

Time range: 68.7-1438.5 seconds (1.1-24 minutes)
Mass range: 78.0343-540.5056 m/z
Peaks: 226 (about 75 per sample)
Peak Groups: 23
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 6086
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.505 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset)
...
...
> paf4f@f4f_link_type
[1] "individual"
> nrow(paf4f@grped_df)
[1] 50
> paf4f@fileMatch
                                                         MS1
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
2 ./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML
3 ./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML
                                                         MS2
1 ./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
2 ./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML
3 ./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML
```

###### Mix Laberca
Test with `Mix_Laberca` (006_deux) :

```R

```

###### Boldenone Yann
Test with `Boldenone_yann` :

```R
> filepathsMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> pa<-purityA(filepathsMS2)
...
...
> nrow(pa@puritydf)
[1] 9201
> pa@fileListMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> pa@fileListMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> pa@fileMatch
                                                       MS1
1 ./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML
                                                       MS2
1 ./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 1.7-1318.8 seconds (0-22 minutes)
Mass range: 65.02-973.5861 m/z
Peaks: 9776 (about 9776 per sample)
Peak Groups: 1497
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 10245
Profile settings: method = bin
                  step = 0.1

Memory usage: 1.26 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset)
...
...
> paf4f@f4f_link_type
[1] "individual"
> nrow(paf4f@grped_df)
[1] 4530
> paf4f@fileMatch
                                                       MS1
1 ./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML
                                                       MS2
1 ./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML
```

So, this tool looks working good with this kind of files. I just have to add the verification of rows in fileMatch.

</details>

#### For files with only MS or MS/MS datas
This modification is the harder. Where we didn't really need file names, now we have to match MS and MS/MS files together to not mix them. We also have to take care of what each file contain and how the user want to study it. For example one file containing MS and MS/MS data can be run with one file containing only MS/MS datas and it has to be process on only its MS datas. I made some graphs trying to develop all possibilities of study we can have with different msLevel of inputs.

<details><summary>Development and testing</summary>

##### Development

![Graph files MSonly and MSMSonly](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MSpurity/graph_file_MSonly_and_MSMSonly.jpg?raw=true)

Here is the first possibility I explored. When you have one file containing MS datas and one file containing MS/MS datas. The first file is processed by xcms normally and the second one enter in assess-purity tool. But this tool process the input to obtain its precursor. Precursors of each MS/MS scans are not in the MS/MS file, they are in the MS file. So, we also have to take this file as input. But it is not finish because how do we know which MS file is linked with which MS/MS file ? We also need a CSV file where we just have to fix the MS file name, then the MS/MS file name. It should look like that :
```
MSfile_1.mzML;MSMSfile_1.mzML
```
It is important to put first the MS file, then the MS/MS file ! We will need this CSV file always when we have different files for MS and MS/MS.
##### Testing

###### STD_MIX 1
Test with `STD_MIX1` with only MS or only MS/MS :

```R
> filepathsMS1
[1] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
> filepathsMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
> CSVfile
[1] "./test-data/CSVfile_STD_MIX1_MSonly_with_MSMSonly.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 4894
> pa@fileListMS1
[1] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
> pa@fileListMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
> pa@fileMatch
                                   MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 121.8-1435 seconds (2-23.9 minutes)
Mass range: 78.0343-381.337 m/z
Peaks: 78 (about 78 per sample)
Peak Groups: 57
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 1123
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.187 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 4
> paf4f@fileMatch
                                   MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
```
It's strange that we obtain only 4 matches...!

###### STD_MIX 1, STD_MIX 2 and STD_MIX 3
Test with `STD_MIX1`, `STD_MIX2` and `STD_MIX3` with only MS or only MS/MS :

```R
> filepathsMS1
[1] "./test-data/MS1/STD_MIX3_60stepped_1E5_Top5_MS1.mzML"
[2] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
[3] "./test-data/MS1/STD_MIX2_60stepped_1E5_Top5_MS1.mzML"
> filepathsMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
[2] "./test-data/MS2/STD_MIX3_60stepped_1E5_Top5_MS2.mzML"
[3] "./test-data/MS2/STD_MIX2_60stepped_1E5_Top5_MS2.mzML"
> CSVfile
[1] "./test-data/CSVfile_STD_MIX1-2-3_MSonly_with_MSMSonly.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 14828
> pa@fileListMS1
[1] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
[2] "./test-data/MS1/STD_MIX2_60stepped_1E5_Top5_MS1.mzML"
[3] "./test-data/MS1/STD_MIX3_60stepped_1E5_Top5_MS1.mzML"
> pa@fileListMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
[2] "./test-data/MS2/STD_MIX2_60stepped_1E5_Top5_MS2.mzML"
[3] "./test-data/MS2/STD_MIX3_60stepped_1E5_Top5_MS2.mzML"
> pa@fileMatch
                                   MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
2 STD_MIX2_60stepped_1E5_Top5_MS1.mzML STD_MIX2_60stepped_1E5_Top5_MS2.mzML
3 STD_MIX3_60stepped_1E5_Top5_MS1.mzML STD_MIX3_60stepped_1E5_Top5_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 3 samples

Time range: 68.7-1438.5 seconds (1.1-24 minutes)
Mass range: 78.0343-540.5056 m/z
Peaks: 226 (about 75 per sample)
Peak Groups: 23
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 1123
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.505 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 9
> paf4f@fileMatch
                                   MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
2 STD_MIX2_60stepped_1E5_Top5_MS1.mzML STD_MIX2_60stepped_1E5_Top5_MS2.mzML
3 STD_MIX3_60stepped_1E5_Top5_MS1.mzML STD_MIX3_60stepped_1E5_Top5_MS2.mzML
```

###### Mix Laberca
Test with `Mix_Laberca` (006+006_deux) :

```R

```

###### Boldenone Yann
Test `Boldenone_yann` :

```R
> filepathsMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSonly.mzML"
> filepathsMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSMSonly.mzML"
> CSVfile
[1] "./test-data/Boldenone_yann/CSV_MSonly_MSMSonly.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 9201
> pa@fileListMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSonly.mzML"
> pa@fileListMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSMSonly.mzML"
> pa@fileMatch
                         MS1                          MS2
1 Boldenone_yann_MSonly.mzML Boldenone_yann_MSMSonly.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 1.7-1318.8 seconds (0-22 minutes)
Mass range: 65.02-973.5861 m/z
Peaks: 9776 (about 9776 per sample)
Peak Groups: 1497
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 1044
Profile settings: method = bin
                  step = 0.1

Memory usage: 1.26 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 97
> paf4f@fileMatch
                         MS1                          MS2
1 Boldenone_yann_MSonly.mzML Boldenone_yann_MSMSonly.mzML
```

</details>

#### For MS files containing also MS/MS and files with only MS/MS
In this case we just have to select only MS datas from the first file. It can be done easily with the function `filterMSlevel` set at 1.
<details><summary>Development and testing</summary>

##### Development

![Graph files MSonly and MSMSonly](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MSpurity/graph_file_MSandMSMS_MSMSonly.jpg?raw=true)

This third graph shows the workflow when we have a file for MS datas which contains also MS/MS datas and a file for MS/MS with only MS/MS datas. It is the same things that the previous one. That's because we have this line which can select only MS datas when you take as input a file containing ms and MS/MS datas :
```R
raw_data <- MSnbase::readMSData(files=fileToLoad, pdata = new("NAnnotatedDataFrame", pd), mode="onDisk")
ms1 <- raw_data@featureData@data[raw_data@featureData@data$msLevel==1,]$seqNum
```


With it, you can put MS only files or MS and MS/MS files as input for MS files with no problems.


##### Testing

###### STD_MIX 1
Test with `STD_MIX1` with MS and MS/MS for MS and only MS/MS for MS/MS :

```R
> filepathsMS1
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> filepathsMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
> CSVfile
[1] "./test-data/CSVfile_STD_MIX1_MSandMSMS_withMSMSonly.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 4894
> pa@fileListMS1
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileListMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
> pa@fileMatch
                                       MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 121.8-1435 seconds (2-23.9 minutes)
Mass range: 78.0343-381.337 m/z
Peaks: 78 (about 78 per sample)
Peak Groups: 57
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 6017
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.187 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 38
> paf4f@fileMatch
                                       MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
```

###### STD_MIX 1, STD_MIX 2 and STD_MIX 3
Test with `STD_MIX1`, `STD_MIX2`, and `STD_MIX3` with MS and MS/MS for MS and only MS/MS for MS/MS :

```R
> filepathsMS1
[1] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
> filepathsMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
[2] "./test-data/MS2/STD_MIX3_60stepped_1E5_Top5_MS2.mzML"
[3] "./test-data/MS2/STD_MIX2_60stepped_1E5_Top5_MS2.mzML"
> CSVfile
[1] "./test-data/CSVfile_STD_MIX1-2-3_MSonly_with_MSMSonly.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 14828
> pa@fileListMS1
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileListMS2
[1] "./test-data/MS2/STD_MIX1_60stepped_1E5_Top5_MS2.mzML"
[2] "./test-data/MS2/STD_MIX2_60stepped_1E5_Top5_MS2.mzML"
[3] "./test-data/MS2/STD_MIX3_60stepped_1E5_Top5_MS2.mzML"
> pa@fileMatch
                                       MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
2 STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX2_60stepped_1E5_Top5_MS2.mzML
3 STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX3_60stepped_1E5_Top5_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 3 samples

Time range: 68.7-1438.5 seconds (1.1-24 minutes)
Mass range: 78.0343-540.5056 m/z
Peaks: 226 (about 75 per sample)
Peak Groups: 23
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 6086
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.505 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 42
> paf4f@fileMatch
                                       MS1                                  MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX1_60stepped_1E5_Top5_MS2.mzML
2 STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX2_60stepped_1E5_Top5_MS2.mzML
3 STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML STD_MIX3_60stepped_1E5_Top5_MS2.mzML
```

###### Mix Laberca
Test with `Mix_Laberca` (006_deux+006) :

```R

```

###### Boldenone Yann
Test `Boldenone_yann` :

```R
> filepathsMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> filepathsMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSMSonly.mzML"
> CSVfile
[1] "./test-data/Boldenone_yann/CSV_MSandMSMS_MSMSonly.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 9201
> pa@fileListMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> pa@fileListMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSMSonly.mzML"
> pa@fileMatch
                            MS1                          MS2
1 Boldenone_yann_MSandMSMS.mzML Boldenone_yann_MSMSonly.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 1.7-1318.8 seconds (0-22 minutes)
Mass range: 65.02-973.5861 m/z
Peaks: 9776 (about 9776 per sample)
Peak Groups: 1497
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 10245
Profile settings: method = bin
                  step = 0.1

Memory usage: 1.26 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 693
> paf4f@fileMatch
                            MS1                          MS2
1 Boldenone_yann_MSandMSMS.mzML Boldenone_yann_MSMSonly.mzML
```

</details>

#### For MS files with only MS and MS/MS files with also MS datas
Here its harder to obtain the good datas. We know that after msConvert, MS/MS datas has already precursor informations when the file contains also MS datas. So, here MS/MS files contain precursors informations. I have to add a variable call `forcedMS1` which is able to select what the user want to do with these precursors informations. If this variable is set to "TRUE", all precursors informations are delete and we obtain new ones with the MS datas containing in MS file. If `forcedMS1` set to "FALSE", precursors informations are kept and the MS file isn't really necessary... By default `forcedMS1` set to "TRUE" but users can change it if they want but this could be the same thing as having only one input with MS and MS/MS datas in one file.

<details><summary>Development and testing</summary>

Where you can have some problems is when you will want to put as MS/MS file a file containing MS and MS/MS datas. The different workflows are in the following graph :
##### Development

![Graph files MSonly and MSMSonly](https://github.com/jsaintvanne/MyMSMSstudy/blob/develop/MSpurity/graph_file_MSonly_MSandMSMS.jpg?raw=true)

It is quite the same workflow as previous ones. There is just a little variable introduce for which the user has to choose to set at "true" or "false". Why have I introduced this variable ? When you have MS and MS/MS datas in one file, the MS/MS datas already have their precursor scan. It is when you convert your raw file into a mzML file that you chose to keep MS and MS/MS datas. So, all the MS/MS scans of this file have their own MS scan already define. The user may want to use an other MS file to run the tool and to study his MS/MS datas. In this case, you have to check the variable "forcedMS1" to "true". That will force the script to use datas from the MS file which match with the MS/MS file (which one contains also MS datas). Like this we will search for MS scans which are in the MS file and we don't pay attention about precursors already defined.
##### Testing

###### STD_MIX 1
Test with `STD_MIX1` with MS only for MS and MS and MS/MS for MS/MS :

```R
> filepathsMS1
[1] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
> filepathsMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> CSVfile
[1] "./test-data/CSVfile_MSonly_MSandMSMS.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 4894
> pa@fileListMS1
[1] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
> pa@fileListMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileMatch
                                   MS1                                      MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 121.8-1435 seconds (2-23.9 minutes)
Mass range: 78.0343-381.337 m/z
Peaks: 78 (about 78 per sample)
Peak Groups: 57
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 1123
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.187 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 5
> paf4f@fileMatch
                                   MS1                                      MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
```

###### STD_MIX 1, STD_MIX 2 and STD_MIX 3
Test with `STD_MIX1`, `STD_MIX2`, and `STD_MIX3` with MS and MS/MS for MS and only MS/MS for MS/MS :

```R
> filepathsMS1
[1] "./test-data/MS1/STD_MIX2_60stepped_1E5_Top5_MS1.mzML"
[2] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
[3] "./test-data/MS1/STD_MIX3_60stepped_1E5_Top5_MS1.mzML"
> filepathsMS2
[1] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
> CSVfile
[1] "./test-data/CSVfile_STD_MIX1-2-3_MSonly_with_MSandMSMS.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 14828
> pa@fileListMS1
[1] "./test-data/MS1/STD_MIX1_60stepped_1E5_Top5_MS1.mzML"
[2] "./test-data/MS1/STD_MIX2_60stepped_1E5_Top5_MS1.mzML"
[3] "./test-data/MS1/STD_MIX3_60stepped_1E5_Top5_MS1.mzML"
> pa@fileListMS2
[1] "./test-data/MS1+2/STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML"
[2] "./test-data/MS1+2/STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML"
[3] "./test-data/MS1+2/STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML"
> pa@fileMatch
                                   MS1                                      MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
2 STD_MIX2_60stepped_1E5_Top5_MS1.mzML STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML
3 STD_MIX3_60stepped_1E5_Top5_MS1.mzML STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML
```
```R
> xset
An "xcmsSet" object with 3 samples

Time range: 68.7-1438.5 seconds (1.1-24 minutes)
Mass range: 78.0343-540.5056 m/z
Peaks: 226 (about 75 per sample)
Peak Groups: 23
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 1123
Profile settings: method = bin
                  step = 0.1

Memory usage: 0.505 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 8
> paf4f@fileMatch
                                   MS1                                      MS2
1 STD_MIX1_60stepped_1E5_Top5_MS1.mzML STD_MIX1_60stepped_1E5_Top5_MS1_MS2.mzML
2 STD_MIX2_60stepped_1E5_Top5_MS1.mzML STD_MIX2_60stepped_1E5_Top5_MS1_MS2.mzML
3 STD_MIX3_60stepped_1E5_Top5_MS1.mzML STD_MIX3_60stepped_1E5_Top5_MS1_MS2.mzML
```

###### Mix Laberca
Test with `Mix_Laberca` (006_deux+006) :

```R

```

###### Boldenone Yann
Test `Boldenone_yann` :

```R
> filepathsMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSonly.mzML"
> filepathsMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> CSVfile
[1] "./test-data/Boldenone_yann/CSV_MSonly_MSandMSMS.csv"
> pa<-purityA(filepathsMS2=filepathsMS2,filepathsMS1=filepathsMS1,CSVfile=CSVfile)
...
...
> nrow(pa@puritydf)
[1] 9201
> pa@fileListMS1
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSonly.mzML"
> pa@fileListMS2
[1] "./test-data/Boldenone_yann/Boldenone_yann_MSandMSMS.mzML"
> pa@fileMatch
                         MS1                           MS2
1 Boldenone_yann_MSonly.mzML Boldenone_yann_MSandMSMS.mzML
```
```R
> xset
An "xcmsSet" object with 1 samples

Time range: 1.7-1318.8 seconds (0-22 minutes)
Mass range: 65.02-973.5861 m/z
Peaks: 9776 (about 9776 per sample)
Peak Groups: 1497
Sample classes: .

Feature detection:
 o Peak picking performed on MS1.
 o Scan range limited to  1 - 1044
Profile settings: method = bin
                  step = 0.1

Memory usage: 1.26 MB
> pa
[1] "purityA object for assessing precursor purity for MS/MS spectra"
> paf4f<-frag4feature(pa,xset,use_group=TRUE)
...
...
> paf4f@f4f_link_type
[1] "group"
> nrow(paf4f@grped_df)
[1] 105
> paf4f@fileMatch
                         MS1                           MS2
1 Boldenone_yann_MSonly.mzML Boldenone_yann_MSandMSMS.mzML
```

</details>
