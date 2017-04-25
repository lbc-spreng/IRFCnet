function PvalCol = singleObsPval(curBetaMap, Parcel)
%given the beta map for an individual event, obtain a pvalue for each
%region

if sum(size(Parcel.img) == size(curBetaMap)) ~= 3
    error ('Parcel and event nifti files do not have the same number of voxels')
end

PvalCol = zeros(Parcel.TotSize, 1);
for parc = Parcel.labels.' 
    pbetas = curBetaMap(Parcel.img == parc);
    %if a region has >100 voxels, randomly choose a subset
    %to keep power consistent across regions
    if size(pbetas, 1) > 100
       pbetas = pbetas(randsample(1:size(pbetas,1), 100)); 
    end
    zscore =  mean(pbetas)/sqrt(var(pbetas)/size(pbetas,1));
    PvalCol(Parcel.labels == parc) = 1-normcdf(zscore);
end


end

