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

```
sdcm -verbose -folder @mri_tags.sdcm -method link /Volumes/T7/data T7
cd T7 && ../dir2csv.py -i . -o ../mri.csv
```

## Step 2

Extract the intent from the accidental fields as a new column. Use a CART model to learn the intent from the physical scan parameters.

