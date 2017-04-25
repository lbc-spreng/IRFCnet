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
IRFCnet(workdir, parcels, subjectID, condName, baseName, GLMregions, gamma, bonf)
```

Arguments
-------------------  

All nifti files must have the same dimension.

-`workdir`: string containing the directory where all data is located

-`parcels`: string ending in `".nii"` that gives the name of the nifti file located in `workdir` that has the parcellation of the brain of interest.  This parcellation must have voxels set to 0 if the voxel is not in a parcellation, and a voxel is set to numeric `r` if that voxel is located in r^th parcel. 

-`subjectID`: a `1xM` cell object containing a string ID for each subject.  Assume each subject has a folder within `workdir` with their corresponding subjectID that contains all their data.  E.g. if subjectID(1) == '001', then the folder `workdir/001` will contain all of that subject's data

-`condName`: a `1xK` cell object containing a string giving placement of each condition's fitted beta map in .nii format within any subjectID folder.  For example if a subjectID is 001, and `condName = {"con1/beta.nii", "con2/beta.nii"}` then there is a beta map located in workdir/001/con1/beta.nii and workdir/001/con2/beta/nii.

-`baseName`: a `1xK` cell object similar to `condName`.  Gives the placement of any baseline betamaps for comparing conditions to. **Even if the baseline is the same for multiple conditions, there file still must be duplicated, as there must be an `nii` file for each condition.**

-`GLMregions`: a numeric vector giving the parcel number for all parcels that were selected as significantly activating (across time) from the traditional GLM.

-`gamma`: a numeric giving the specificity of the network edge selection.  Corresponds to the EBIC gamma parameter.  **Defaults to 0.25**

-`bonf`: a numeric corresponding to the pvalue correction.  **Defaults to the number of regions in the parcellation, corresponding to the bonferonni correction.**


Value
-------------------  

-`weiadj`: a weighted adjacency matrix such that the i^th where rows correspond to parcel IDs.  If parcIDs is a vector of all parcel IDs (excluding 0), then the i^th row corresponds to the `sort(parcIDs)(i)` parcel (e.g. the i^th smallest parcel ID).  

-`lambda_optval`: the optimal fitted regularization parameter for each parcel.

-`PvalNet`: a matrix that gives pvalues for each observation and region.  This is a (number of parcels)x(number of conditions * number of subjects) matrix.

-`ObNet`: the observed state of each region. Obtained by thresholding the PvalNet. Has the same structure as `PvalNet`

Manual fit
-------------------  

Running the following function with the same arguments as above will give an uncorrected pvalue network. 


```r
cd(workdir)
PvalNet = Pnet(parcels, subjectID, condName, baseName) 
ObNet = PvalNet < 0.05/bonf
```

If `numparc` is the number of parcels and `numObs` is the number of observations, then `Net` outputs a `numparc X numObs` matrix which gives the an on/off state for each region at each observation.

This thresholding is done via a bonferonni correction, that can be edited easily if another threshold is of interest.



2. **Fitting Network**

Running the following function on Net will output the weighted adjacency matrix


```r
Out = IsingFitEx(ObNet.', GLMregions, 0.25, TRUE)
```

Here `0.25` corresponds to the`gamma` variable corresponds to the EBIC information criterion and penalizes the number of edges.  The `TRUE` corresponds to an `AND` variable.  Being `TRUE` means an edge is only included between any regions A and B if: B was selected as a neighbor of A **AND** A was selected as a neighbor of B.  If `AND` is `FALSE` then the bolded **AND** is switched to **OR**.


Example using IRFCexample.zip
-------------------  

Here we provide an example for how the fitting function can be used.

The file `IRFCexample.zip` gives an example of how directories must be set up in order to use the method. 

In this example, variables for the function can be defined as follows:


```r
workdir = './IRFCexample';
parcels = 'parc.nii';
subjectID = {'sub1' 'sub2' 'sub3'};
condiName = {'con1.nii' 'con2.nii'};
baseName = {'bas1.nii' 'bas2.nii'};
GLMregions = [1 2 3 4]
```

Note that the working directory must be changed to correspond to the location of the unzipped `IRFCexample` folder on your computer.  In this example Pnet can be run, although in order to save space, the nifti files are too small to have enough variance to be fit.  



No Baseline beta map?
-------------------  

If you have no baseline betamap for your conditions (e.g. the condition betamaps already correspond to an estimated contrast), you can create an empty nifti file as follows, which can be copied to your subdirectories.  When your condition file has dimension `n1 X n2 X n3`, you can create a baseline nifti file with the following code. 


```r
baseliVec = zeros(1, n1*n2*n3);
baseliArr = reshape(baseliVec, n1, n2, n3);
baseliNii = make_nii(baseliArr);
save_nii(baseliNii, 'bas.nii')
```

Note that this code uses the Tools for Nifti and Analyze Image package mentioned at the beginning of this file.