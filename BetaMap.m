function curBetaMap = BetaMap(subID, eName, bName)
%for an individual subjectID (string), eventName (string) and baselineName
%(string), outputs array corresponding to the event beta map corrected by
%the baseline

eBeta = load_nii([subID '/' eName]);
bBeta = load_nii([subID '/' bName]);


if size(size(eBeta.img),2) ~= 3
    error ('event nifti files has more than 3 dimensions')
end

if size(size(bBeta.img),2) ~= 3
    error ('basline nifti files has more than 3 dimensions')
end

if sum(size(eBeta.img) == size(bBeta.img)) ~= 3
    error ('event and baseline nifti files do not have the same number of voxels')
end


curBetaMap = eBeta.img - bBeta.img;

end

