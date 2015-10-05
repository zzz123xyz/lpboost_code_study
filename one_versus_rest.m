function [out,svm_alpha,svm_b] = one_versus_rest(Y,K,C,l1,train_ind,test_ind);

warning('off','MATLAB:dispatcher:pathWarning');
addpath code/libsvm-matlab/
warning('on','MATLAB:dispatcher:pathWarning');

% can pass file to gram matrix
if isstr(K), load(K,'K'); end

nClasses = numel(unique(Y));

out = zeros(numel(test_ind),nClasses);
for c=1:nClasses % for all classes

    tmpY = double(Y(train_ind)==c);
    tmpY(tmpY==0) = -1;
    assert(numel(unique(tmpY))==2);
    
    [alpha,b] = libsvm(tmpY,K(train_ind,train_ind),C,[],l1,'svm_eps',1e-4);
   
    out(:,c) = K(test_ind,train_ind)*alpha+b;
    
    svm_alpha{c} = alpha;
    svm_b{c} = b;

    fprintf('%d of %d done\r',c,nClasses);
end

fprintf('\n');
return;