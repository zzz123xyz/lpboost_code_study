% ypred = mclp_predict(score,B)
%
% input: 
%	- score (nExamples,nClasses,nWeakClassifiers)
%	- B (nClasses,nWeakClassifiers) for LP-B or 
%	  B (1,nWeakClassifiers) for LP-beta
%
% Peter Gehler
function ypred = mclp_predict(score,B)

ypred = zeros(size(score,1),1);
for i=1:size(score,1)
    D=squeeze(score(i,:,:))*B;
    if size(D,1)==size(D,2) % in mcl we predict along the diagonal
	D=diag(D);
    end
    D = D + 1e-9 * randn(size(D));
    ypred(i,1) = find(D==max(D(:)));
end

