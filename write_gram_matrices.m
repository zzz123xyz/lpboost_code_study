% write_gram_matrices(splitfile,featnum)
%
% collect the data of feature 'featnum' and use the split
% 'splitfile' to create the Gram matrix needed for subsequent
% training
%function status = write_gram_matrices(splitfile,featnum)
%
function status = write_gram_matrices(dataset,nTrain,nTest,splitNr,featnum)

splitfile = sprintf('splits/caltech%s_nTrain%d_nTest%d_N%d.mat',dataset,nTrain,nTest,splitNr);

status = 1;

warning off
addpath code/libsvm-matlab
addpath code/mpi-chi2
warning on

load_features
feature = f{featnum};

fprintf('processing %s\n',explain_feature(feature));

gramfilename = create_gramfilename(splitfile,featnum);
gramtestfile = strrep(gramfilename,'_feat','_test_feat');

% choose the correct kernel
switch feature.type
 case {'regcov','regcovn','regcovn2','v1plus'}
  kernel = 'linear';
 case {'v1plus_rbf','regcovn_rbf'}
  kernel = 'gauss';
case 'product'
  kernel = 'void';
 otherwise
  kernel = 'chi2';
end
fprintf(['using a ',kernel,' kernel\n']);

if exist(gramfilename,'file')&exist(gramtestfile,'file')
    return;
end

if isfield(feature,'depends')
    tmp_gramfilename = create_gramfilename(splitfile,feature.depends);
    tmp_gramtestfile = strrep(tmp_gramfilename,'_feat','_test_feat');
    if (exist(tmp_gramfilename,'file') &&exist(tmp_gramtestfile,'file')), return; end
end

load(splitfile,'tr_files','class','te_files');

%
% Concatenation: 
%
if strcmp(feature.type,'product')
    tmpD = single(0); tmpDtest=single(0);

    % load the gram matrices of the associated features and extract
    % the distance matrices.
    for ff=feature.prodInd
	thisFeature = f{ff};
	tmp_gramfilename = create_gramfilename(splitfile,ff);
	tmp_gramtestfile = strrep(tmp_gramfilename,'_feat','_test_feat');
	if ~exist(tmp_gramfilename,'file'),  error(['file ''',tmp_gramfilename,'''does not exist']);end
	if ~exist(tmp_gramtestfile,'file'),  error(['file does not exist']);end
	clear K kernparam;
	load(tmp_gramfilename,'K','kernparam');
	switch thisFeature.type
	 case 'regcovn_rbf'
	  gamma = 2*(kernparam.gamma^2);
	 case {'phog','app','lbp'}
	  gamma = kernparam;
	 otherwise
	  error('not implemented');
	end
	D = -gamma * log(K+eps);
	tmpD = tmpD + D;
	clear K
	load(tmp_gramtestfile,'K');
	D = -gamma * log(K+eps);
	tmpDtest = tmpDtest + D;
    end

    kernparam = mean(tmpD(:));
    K = exp(-tmpD./kernparam);
    assert(K(1,1)==1);
    save(gramfilename,'K','kernparam');
    K = exp(-tmpDtest./kernparam);
    save(gramtestfile,'K');

    return;

elseif strcmp(feature.type,'avg')

    % these features are averages over Gram matrices of other
    % features. Load them and average
    tmpK = single(0); tmpKtest=single(0);
    D = single(0); Dtest=single(0);
    %reverse for efficiency reasons, no preference.
    for f=sort(feature.avgInd,'descend')
	tmp_gramfilename = create_gramfilename(splitfile,f);
	tmp_gramtestfile = strrep(tmp_gramfilename,'_feat','_test_feat');
	if ~exist(tmp_gramfilename,'file'),  error(['file ''',tmp_gramfilename,'''does not exist']);end
	if ~exist(tmp_gramtestfile,'file'),  error(['file does not exist']);end
	load(tmp_gramfilename,'K','kernparam');
	kparam(f) = kernparam;
	tmpK = tmpK + K;
	D = D - kernparam*log(K+eps);
	load(tmp_gramtestfile,'K');
	tmpKtest = tmpKtest + K;
	Dtest = Dtest - kernparam*log(K+eps);
	fprintf('f%d.',f);
    end
    D = D./numel(feature.avgInd);
    Dtest = Dtest./numel(feature.avgInd);

    % now save the results
    K = tmpK./numel(feature.avgInd); clear tmpK
    assert(K(1,1)==1);
    kernparam = kparam;
    save(gramfilename,'K','kernparam');
    save(strrep(gramfilename,'.mat','_dist.mat'),'D'); clear D
    
    K = tmpKtest./numel(feature.avgInd);clear tmpKtest
    save(gramtestfile,'K');
    D = Dtest;clear Dtest;
    save(strrep(gramtestfile,'.mat','_dist.mat'),'D'); clear D

    % delete the matrices to free up space
    if ismember(featnum,[630,631,632,309,310,794,895])
        for f=sort(feature.avgInd,'descend')
	    tmp_gramfilename = create_gramfilename(splitfile,f);
	    tmp_gramtestfile = strrep(tmp_gramfilename,'_feat','_test_feat');
	    system(['rm -f ',tmp_gramfilename]);
	    system(['rm -f ',tmp_gramtestfile]);
	end
    end
    
    % nothing more to do
    return;
end


if isfield(feature,'indxWindow')&feature.indxWindow>0

    fprintf('feature with subwindow index %d\n',feature.indxWindow);
    assert(numel(feature.indxWindow)==1);
    K = 0; Ktest = zeros(numel(te_files),numel(tr_files),'single');
    fprintf('computing gram matrix no %d...',feature.indxWindow);
    X = collect_features(feature,tr_files,dataset,splitfile,class,feature.indxWindow);
    switch kernel
     case 'chi2'
      D = chi2dist(X);
      kernparam = mean(D(:));
      K = single(chi2(X,X,kernparam,D));
     otherwise
      error('no such kernel');
    end
    % gather the test data in batches.
    for k=0:500:numel(te_files)
	batchsize = min(numel(te_files)-k,500);
	Xte = collect_features(feature,{te_files{k+(1:batchsize)}},dataset,splitfile,class,feature.indxWindow);
	assert(size(Xte,1)==batchsize);
	switch kernel
	 case 'chi2'
	  Ktest(k+(1:batchsize),:) = single(chi2(Xte,X,kernparam));
	 otherwise
	  error('no such kernel yet');
	end
	fprintf('%d of %d done\n',k,numel(te_files))
    end
    fprintf('done\n');

else
    fprintf('collecting training features...');
    Ktest = zeros(numel(te_files),numel(tr_files));
    X = collect_features(feature,tr_files,dataset,splitfile,class);
    fprintf('done\n');
    
    switch kernel
     case 'gauss'
      % subtract mean
      meanX = mean(X);
      for k=0:500:size(X,1)
	  batchsize = min(size(X,1)-k,500);
	  X(k+(1:batchsize),:) = X(k+(1:batchsize),:)-repmat(meanX,batchsize,1);
      end
      % unit variance
      for k=0:500:size(X,2)
	  batchsize = min(size(X,2)-k,500);
	  stdX(1,k+(1:batchsize)) = std(X(:,k+(1:batchsize)));
      end
      for k=0:500:size(X,1)
	  batchsize = min(size(X,1)-k,500);
	  X(k+(1:batchsize),:) = X(k+(1:batchsize),:)./repmat(stdX+eps,batchsize,1);
      end
      kernparam.meanX = meanX;clear meanX
      kernparam.stdX = stdX;clear stdX

      % compute kernel matrix
      D = zeros(size(X,1),size(X,1));
      for k=0:500:size(X,1)
 	  batchsize = min(size(X,1)-k,500);
	  D(k+(1:batchsize),:) = dist_euclid(X(k+(1:batchsize),:),X);
      end
      kernparam.gamma = sqrt(mean(D(:))/2);
      K = rbf(X,X,kernparam.gamma,D);
      K = single(K);
     case 'chi2'
      D = chi2dist(X);
      kernparam = mean(D(:));
      K = chi2(X,X,kernparam,D); clear D;
      K = single(K);
     case 'linear'
      if strcmp(feature.type,'v1plus')
	  meanX = mean(X);
	  X = X-repmat(meanX,size(X,1),1);
	  stdX = sqrt(var(X));
	  X = X./repmat(stdX+eps,size(X,1),1);
	  K = X*X';
	  kernparam.meanX = meanX;
	  kernparam.stdX = stdX;
      else
	  K = X*X';
	  kernparam = K(1,1);
	  K = K./K(1,1); % NORMALIZE (features might be ||f||_2=1) 
      end
     otherwise
      error('no such kernel');
    end
    %
    % now collect the test data in batches to save memory
    %
    fprintf('collecting test features...');
    for k=0:500:numel(te_files)
	batchsize = min(numel(te_files)-k,500);
	Xte = collect_features(feature,{te_files{k+(1:batchsize)}},dataset,splitfile,class);
	assert(size(Xte,1)==batchsize);
	switch kernel
	 case 'gauss'
	  Xte = Xte-repmat(kernparam.meanX,size(Xte,1),1);
	  Xte = Xte./(repmat(kernparam.stdX+eps,size(Xte,1),1));
	  Ktest(k+(1:batchsize),:) = rbf(Xte,X,kernparam.gamma);
	 case 'chi2'
	  tic
	  Ktest(k+(1:batchsize),:)=chi2(Xte,X,kernparam);
	  fprintf('chi2:');toc;
	 case 'linear'
	  if strcmp(feature.type,'v1plus')
	      Xte = Xte-repmat(kernparam.meanX,size(Xte,1),1);
	      Xte = Xte./(repmat(kernparam.stdX+eps,size(Xte,1),1));
	      Ktest(k+(1:batchsize),:) = Xte*X';
	  else
	      Ktest(k+(1:batchsize),:) = Xte*X';
	      Ktest(k+(1:batchsize),:) = Ktest(k+(1:batchsize),:)./kernparam; % NORMALIZE
	  end
	end
	fprintf('%d of %d done\n',k+batchsize,numel(te_files));
    end
    fprintf('done\n');
end

K = single(K);
assert(size(K,1)==numel(tr_files))
assert(size(K,2)==numel(tr_files))
save(gramfilename,'K','kernparam');
clear K
K = single(Ktest);
assert(size(K,1)==numel(te_files))
assert(size(K,2)==numel(tr_files))
save(gramtestfile,'K');

