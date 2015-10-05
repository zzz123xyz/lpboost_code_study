% [classifierfile,Ypred] = mkltrain_combination(splitfile,combnum,method,optimalC)
%
% Train a MKL classifier on split 'splitfile' and combination
% 'combnum' (see load_combinations)
% 'method' - Possible values are 'average','silp','product','varma'
%	     'simplemkl','linear_empkernel_logistic','linear_multiclass'
%
% optimalC (1000) - regularization constantC
%
% Peter Gehler
function [classifierfile,Ypred] = mkltrain_combination(splitfile,combnum,method,optimalC)

if ~isstr(splitfile), error('input error'); end
if ~isstr(method), error('input error'); end

load_settings;

load_combinations;
featnums = combination{combnum};

svm_eps = 1e-5;
mkl_eps = 1e-4;

clear f;
load_features
featnums = sort(unique(featnums));

warning('off','MATLAB:dispatcher:pathWarning');
addpath('code/mkl');
addpath('code/libsvm-matlab');
addpath('code/mpi-chi2/');
addpath('~nowozin/opt/coin-ipopt-3.3.5/matlab/');
warning('on','MATLAB:dispatcher:pathWarning');

if ~exist('optimalC','var'),optimalC = 1000;end

% just an identifier of where to store the result
switch method
 case 'silp', mklstr = 'mkl';
 case 'simplemkl', mklstr = 'simplemkl';
 case 'varma', mklstr = 'varmamkl';
 case 'average',  mklstr = 'average';
 case 'product',  mklstr = 'product';
 case {'linear_empkernel_l1loss','linear_empkernel_l2loss','linear_empkernel_logistic','linear_multiclass'}
  mklstr = method;
 otherwise
  error('no such algorithm known');
end

load(splitfile,'tr_files','tr_label','class');
Ytr = tr_label;
nClasses = numel(unique(tr_label));
switch method
 case 'linear_multiclass'
  classifierfile = generate_classifierfname(splitfile,method,combnum,0,optimalC);
  doesExist = exist(classifierfile,'file')>0;
 otherwise
  doesExist = true;
  for classnr=1:nClasses
      % we will store the result here...
      classifierfile = generate_classifierfname(splitfile,method,combnum,classnr,optimalC);

      % ... maybe it exists?
      if ~exist(classifierfile,'file'), doesExist = false; end
  end
end

if doesExist ,   fprintf('already computed... return\n');   return;end

% load all gram matrices
fprintf('loading gram matrices...');
cntr = 1;
switch method
 case {'linear_empkernel_l1loss','linear_empkernel_l2loss','linear_empkernel_logistic','linear_multiclass'}
  %
  % load and concatenate the individual matrices. The classifier is
  % linear on this representation ie K=[K1,K2,K3,..]
  % K * alpha
  %
  cntr = 0;
  for featnum=featnums
      gramfile = create_gramfilename(splitfile,featnum);
      load(gramfile,'K','kernparam');
      if ~exist('Ks','var'),Ks = zeros(size(K,1),size(K,2)*numel(featnums),'single');end
      Ks(:,cntr+(1:size(K,2))) = single(K);

      gramfile = strrep(gramfile,'_feat','_test_feat');
      clear K; load(gramfile,'K');
      if ~exist('Ktest','var'),Ktest = zeros(size(K,1),size(K,2)*numel(featnums),'single');end
      Ktest(:,cntr+(1:size(K,2))) = single(K);
      cntr = cntr + size(K,2);
      fprintf('.');
  end
  clear K;
  
  meanK = mean(Ks);
  Ks = Ks - repmat(meanK,size(Ks,1),1);
  varK = sqrt(var(Ks));
  Ks = Ks./repmat(varK,size(Ks,1),1);

  Ktest = Ktest - repmat(meanK,size(Ktest,1),1);
  Ktest = Ktest./repmat(varK,size(Ktest,1),1);
  
  %
  % k = (\prod_{i=1}^F(k_i))^{1/F}
  %
 case 'product'
  tmpD = single(0);Dtest = 0;
  for featnum=featnums
      gramfile = create_gramfilename(splitfile,featnum);
      clear K kernparam
      load(gramfile,'K','kernparam');
      tmpD = tmpD+log(K+eps);

      gramfile = create_gramfilename(splitfile,featnum);
      gramfile = strrep(gramfile,'_feat','_test_feat');
      clear K; load(gramfile,'K');
      Dtest = Dtest + log(K+eps);
      fprintf('.');
  end
  Ks = exp(tmpD./numel(featnums));
  Ktest = exp(Dtest./numel(featnums));
  clear tmpD
 case 'average'
  Ks = single(0); Ktest = single(0);
  for featnum=featnums
      gramfile = create_gramfilename(splitfile,featnum);
      load(gramfile,'K','kernparam');
      Ks = Ks + single(K);
      
      gramfile = create_gramfilename(splitfile,featnum);
      gramfile = strrep(gramfile,'_feat','_test_feat');
      load(gramfile,'K');
      Ktest = Ktest + single(K);
      fprintf('.');
  end 
  Ks = Ks./numel(featnums);
  Ktest = Ktest./numel(featnums);
 otherwise
  %
  % just load the matrices and store them in the 3dim array Ks
  %
  for featnum=featnums
      gramfile = create_gramfilename(splitfile,featnum);
      load(gramfile,'K','kernparam');
      if ~exist('Ks','var'),Ks = zeros(size(K,1),size(K,2),numel(featnums),'single');end
      Ks(:,:,cntr) = single(K);
      
      gramfile = create_gramfilename(splitfile,featnum);
      gramfile = strrep(gramfile,'_feat','_test_feat');
      load(gramfile,'K');
      if ~exist('Ktest','var'),Ktest = zeros(size(K,1),size(K,2),numel(featnums),'single');end
      Ktest(:,:,cntr) = K;
      cntr = cntr + 1;
      fprintf('.');
  end 
end

fprintf('done\n');


fprintf('training final classifier...');
fprintf('fixed C = %d\n',optimalC);

  opts.alg = method;
switch method
 case 'linear_multiclass'
  classifierfile = generate_classifierfname(splitfile,method,combnum,0,optimalC);
  if exist(classifierfile,'file'), return;end
  
  tstart = cputime;
  [ws,alpha,b] = mkltrain(Ytr,Ks,optimalC,mkl_eps,svm_eps,opts);
  ttrain = cputime-tstart;

  classifier.alpha = alpha;
  classifier.ws = ws;
  classifier.b = b;
  
  trainOut = Ks*alpha' + repmat(b',size(Ks,1),1);
  [ignore,trainPred] = max(trainOut,[],2);
  trainErr = avg_class_err(Ytr,trainPred);
  fprintf('trainingErr = %0.4g\n',trainErr);

  out = Ktest*alpha' + repmat(b',size(Ktest,1),1);
  %[ignore,testPred] = max(testOut,[],2);
  save(classifierfile,'classifier','out','trainErr','ttrain');

  
 otherwise
  for classnr=1:nClasses
      % we will store the result here...
      classifierfile = generate_classifierfname(splitfile,method,combnum,classnr,optimalC);

      % ... maybe it exists?
      if exist(classifierfile,'file')
	  fprintf('class %d already done!\n',classnr);
	  continue;
      end

      Y = double(Ytr==classnr);Y(Y==0) = -1;

      tstart = cputime;
      [ws,alpha,b] = mkltrain(Y,Ks,optimalC,mkl_eps,svm_eps,opts);
      ttrain = cputime-tstart;

      classifier{classnr}.ws = ws;
      classifier{classnr}.alpha = alpha;
      classifier{classnr}.b = b;
      classifier{classnr}.C = optimalC;
      fprintf('%d of %d done\n',classnr,nClasses);

      svset = find(alpha~=0);

      switch method
       case {'linear_empkernel_l1loss','linear_empkernel_l2loss','linear_empkernel_logistic'}
	trainPred = sign(Ks*alpha+b);
       case {'product','average'}
	trainPred = sign(Ks*alpha+b);
       otherwise 
	trainPred = sign(Kbeta(Ks(:,svset,:),ws)*alpha(svset) + b);
      end

      trainErr = avg_class_err(Y,trainPred);
      fprintf('trainingErr = %0.4g\n',trainErr);

      
      %
      % do testing 
      %
      cntr = 1;
      switch method
       case {'linear_empkernel_l1loss','linear_empkernel_l2loss','linear_empkernel_logistic'};
	out(:,1) = Ktest(:,svset)*alpha(svset) + b;
       case {'product','average'}
	out(:,1) = Ktest(:,svset)*alpha(svset) + b;
       otherwise
	out(:,1) = Kbeta(Ktest(:,svset,:),ws)*alpha(svset) + b;
      end


      fprintf('done\nsaving...');
      save(classifierfile,'classifier','out','trainErr','ws','alpha','b','ttrain');
      fprintf('done\n');
      clear classifier out trainErr ws alpha b ttrain svset 
  end
end