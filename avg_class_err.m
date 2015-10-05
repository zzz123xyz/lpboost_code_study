% err = avg_class_err(ytrue,ypred)
%
% computes multiclass error as the mean error of all classes
% (standard measure for Caltech). 
%
% 18.03.2009 Peter Gehler
function err = avg_class_err(ytrue,ypred)

if numel(ytrue) ~= numel(ypred)
    error('dimension mismatch');
end

if size(ytrue,1) == 1
    ytrue=ytrue';
end
if size(ypred,1) == 1
    ypred=ypred';
end

classes = sort(unique(ytrue));

for c=1:numel(classes)
    ind = find(ytrue==classes(c));
    correct(c) = mean(ypred(ind)==classes(c));
end

err = 1-mean(correct);
