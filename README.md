IRFC fit in Matlab
======================
David Sinclair  
April 10, 2017

Description
-------------------  

Given directory for beta fits in .nii format, and a parcellation of the brain, obtains a weighted adjacency matrix corresponding to the interregional functional connectivity (IRFC) method. 

Usage
-------------------  

Functions from Matlab packages `Tools for Nifti and Analyze Image` and `glmnet` must be available in the Matlab environment.

Tools for Nifti and Analyze Image: https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

glmnet: http://web.stanford.edu/~hastie/glmnet_matlab/download.html

The function is then run as follows:


```r
IRFCnet(workdir, parcels, subjectID, eventName, baseName, gamma, bonf)
```

Arguments
-------------------  

All nifti files must have the same dimension.

-`workdir`: string containing the directory where all data is located

-`parcels`: string ending in `".nii"` that gives the name of the nifti file located in `workdir` that has the parcellation of the brain of interest.  This parcellation must have voxels set to 0 if the voxel is not in a parcellation, and a voxel is set to numeric `r` if that voxel is located in rth parcel. 

-`subjectID`: a `1xM` cell object containing a string ID for each subject.  Assume each subject has a folder within `workdir` with their corresponding subjectID that contains all their data.  E.g. if subjectID(1) == '001', then the folder workdir/001 will contain all of that subject's data

-`eventName`: a `1xK` cell object containing a string giving placement of each event's fitted beta map in .nii format within any subjectID folder.  For example if a subjectID is 001, and `eventName =  {"event1/beta.nii", "event2/beta.nii"}` then there is a beta map located in workdir/001/event1/beta.nii and workdir/001/event2/beta/nii.

-`baseName`: a `1xK` cell object similar to `eventName`.  Gives the placement of any baseline betamaps for comparing events to. Even if the baseline is the same for multiple events, there file still must be duplicated, as there must be an `nii` file for each event.

-`gamma`: a numeric giving the specificity of the network edge selection.  Corresponds to the EBIC gamma parameter.  Defaults to 0.25

-`bonf`: a numeric corresponding to the pvalue correction.  Defaults to the number of regions in the parcellation, corresponding to the bonferonni correction.


Value
-------------------  

-`weiadj`: a weighted adjacency matrix such that the i^th where rows correspond to parcel IDs.  If parcIDs is a vector of all parcel IDs (excluding 0), then the i^th row corresponds to the `sort(parcIDs)(i)` parcel (e.g. the i^th smallest parcel ID).  

-`lambda_optval`: the optimal fitted regularization parameter for each region.


Manual fit
-------------------  

The above fit function uses a bonferonni correction and an automatically selected model selection parameter.  In order to have more control over the fitting process (and to save the Pvalue network which is time consuming to calculate) the following steps can be followed.

1. **Obtain Pvalue Network.**

Running the following function with the same arguments as above will give an uncorrected pvalue network. 


```r
Pnet = Pnet(workdir, parcels, subjectID, eventName, baseName) 
Net = Pnet < 0.05/bonf
```

If `numparc` is the number of parcels and `numObs` is the number of observations, then `Net` outputs a `numparc X numObs` matrix which gives the an on/off state for each region at each observation.

This thresholding is done via a bonferonni correction, that can be edited easily if another threshold is of interest.


2. **Fitting Network**

Running the following function on Net will output the weighted adjacency matrix


```r
Out = IsingFitEx(Net, 0.25, TRUE)
```

Here `0.25` corresponds to the`gamma` variable corresponds to the EBIC information criterion and penalizes the number of edges.  The `TRUE` corresponds to an `AND` variable.  Being `TRUE` means an edge is only included between any regions A and B if B was selected as a neighbor of A **AND** A was selected as a neighor of B.  If `AND` is `FALSE` then the bolded **AND** is switched to **OR**.


