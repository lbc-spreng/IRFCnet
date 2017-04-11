function PvalNet = Pnet(parcels, subjectID, eventName, baseName)
%Pnet obtains a pvalue for the evidence that a parcel was activated 
%during each event (from evetName) after accounting for a baseline
%(baseName) for each subject.

%load in parcellation and save the parcel labels
Parc = load_nii(parcels);
if size(size(Parc.img),2) ~= 3
    error ('parcel nifti file has more than 3 dimensions')
end
Parc = Parc.img;
Parclab = sort(unique(Parc));
%eliminate '0' parcel
Parclab = Parclab(2:end);
Parcnum = size(Parclab, 1);

%save size of each parcel
Parcsize = zeros(Parcnum,1);
for i = Parclab.'
    Parci = Parc == i;
    Parcsize(i) = sum(Parci(:));
end
Parcel = struct('img', Parc, 'labels', Parclab, 'ParSize', Parcsize, 'TotSize', Parcnum);


%%initialize Pvalue network
%number of events
numObs = size(subjectID,2)*size(eventName,2);
PvalNet = zeros(Parcnum, numObs);


%for each subject, for each event, calculate pvalue
for sub = 1:size(subjectID,2)
    for eve = 1:size(eventName,2) 
        obs = (sub-1)*size(eventName,2) + eve;
        %get beta map (with appropriately corrected baseline) for this event
        curBetaMap = BetaMap(subjectID(sub), eventName(eve), baseName(eve));
        %get pvalues for each parcel corresponding to this betamap
        PvalNet(:,obs) = singleObsPval(curBetaMap, Parcel);
    end
end
  

end

