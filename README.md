# Estimating DICOM intent

Imaging sequences program the scanner to performed a scan for a purpose. We talk about reading **T1-weighted** images or verifying something on a FLAIR. The purpose or **intent** does not map directly to information stored in the DICOM file. Especially for novices it can therefore be difficult to map existing sequence parameter stored in DICOM to the intends like B0, T1, T2*, etc.. 

Instead of experience this project tries to create an algorithm that can perform this assignment from existing DICOM tag values only. No image information is used for this purpose.

## Step 1

Data driven approach: Collect a table of DICOM encoded physical scan parameter for specific imaging modalities like MRI, CT, NM, and US.

One algorithm for each modality should depend on physical scan parameter only. Accidental (entered by a human) measures should be ignored for the prediction step. They may be used for defining intent.

### MRI

Create a folder structure with symbolic links that include scan parameter. Convert the folder structure to a spreadsheet format.

> [!NOTE]
> Indent: ProtocolName, SequenceName, ContrastBolusAgent<br/>
> Physical scan parameter: ScanningSequence, SequenceVariant, ScanOption, RepetitionTime, EchoTime, ...

This step uses the sdcm program which can be downloaded [here](https://github.com/HaukeBartsch/sdcm).

```
# Create a temporary folder T7 from all files in /Volumes/T7/data
sdcm -verbose -folder @mri_tags.sdcm -method link /Volumes/T7/data T7
# Convert the temporary folder tree T7 into a spreadsheet format
cd T7 && ../dirs2csv.py -i . -o ../mri.csv
```

## Step 2

Extract the intent from the accidental fields as a new column. Use a CART model to learn the intent from the physical scan parameters.

Here an example for the such a generated tree:


```
n= 1602 

node), split, n, loss, yval, (yprob)
      * denotes terminal node

 1) root 1602 991 T2 (0 0.33 0.17 0.12 0.38)  
   2) ScanOptions=,CL_GEMS,DIXF,DIXW,EDR_GEMS,EPI_GEMS,FS,PFP,SAT_GEMS,SAT2 1093 569 Diffusion (0 0.48 0.25 0.16 0.11)  
     4) BodyPartExamined=,ABDOMEN,ABDOMENPELVIS,BRAIN,BREAST,HODE,TSPINE,UTERUS,WHOLEBODY 789 267 Diffusion (0 0.66 0 0.21 0.13)  
       8) RepetitionTime>=4400 553  31 Diffusion (0 0.94 0 0.0018 0.054)  
        16) NumberOfPhaseEncodingSteps< 228 376   1 Diffusion (0 1 0 0.0027 0) *
        17) NumberOfPhaseEncodingSteps>=228 177  30 Diffusion (0 0.83 0 0 0.17)  
          34) ScanningSequence=EP 149   2 Diffusion (0 0.99 0 0 0.013) *
          35) ScanningSequence=SE 28   0 T2 (0 0 0 0 1) *
       9) RepetitionTime< 4400 236  75 T1 (0 0 0 0.68 0.32)  
        18) EchoTime< 38.3 162   1 T1 (0 0 0 0.99 0.0062) *
        19) EchoTime>=38.3 74   0 T2 (0 0 0 0 1) *
     5) BodyPartExamined=BODYPART 304  30 REST (0 0.0066 0.9 0.049 0.043)  
      10) ScanningSequence=EP 276   2 REST (0 0.0072 0.99 0 0) *
      11) ScanningSequence=GR,RM,SE 28  13 T1 (0 0 0 0.54 0.46) *
   3) ScanOptions=FAST_GEMS,FC_FREQ_AX_GEMS,IR,NPW,PER,SAT1 509  16 T2 (0 0.002 0 0.029 0.97)  
     6) EchoTime< 11.965 14   0 T1 (0 0 0 1 0) *
     7) EchoTime>=11.965 495   2 T2 (0 0.002 0 0.002 1) *
```