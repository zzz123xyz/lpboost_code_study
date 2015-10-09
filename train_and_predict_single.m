% err = train_and_predict_single(splitfile,featnum,parallel,C)
%
% where
% 'splitfile' - is the definition file for training/test split
% 'featnum' - number of the feature to use (load_features.m)
% 'parallel' - enable parallel processing, splitting up to folds
% 'C' - regularizer
%
% This function computes the classifier for feature 'featnum' on
% the split 'splitfile'
%
% It computes test error, CV error and writes out the predictions
% needed for MCLP training
%
% Peter Gehler
function err = train_and_predict_single(splitfile,featnum,parallel,C)

VERBOSE =1;
if nargout==1, VERBOSE = 0; end

err = Inf;
load_features;
if VERBOSE,fprintf('processing ''%s''\n',explain_feature(f{featnum}));end
clear f;

if ~exist('parallel','var'),parallel=0;end

warning('off','MATLAB:dispatcher:pathWarning');
addpath code/libsvm-matlab
warning('on','MATLAB:dispatcher:pathWarning');


load(strrep(splitfile,'.mat','_cvsplit.mat'),'split');
load_settings;

%
% creating directory to write predictions in 
%
preddir = strrep(splitfile,'splits/','mclp_score/');
preddir = strrep(preddir,'.mat','');

%
% create this file after everything is done
%
done_file = [preddir,'/done_feature',num2str(featnum),'.mat'];	  


preddir = [preddir,'/feature',num2str(featnum),'/'];
if ~exist(preddir,'dir'), system(['mkdir -p ',preddir]);end
if VERBOSE,fprintf('predictions will be stored in ''%s''\n',preddir);end

load(splitfile);

% training data
Ytrain = tr_label;
nClasses = numel(unique(Ytrain));

% and test data
Ytest = te_label;

%
% check if this feature was processed already
%
if exist(done_file,'file')
    if VERBOSE,fprintf('this feature was alerady computed!\n');end
    if VERBOSE,fprintf('delete ''%s'' for redo\n',done_file);end
    load(done_file,'Ypred_test');
    err = avg_class_err(Ytest,Ypred_test);
    if VERBOSE,fprintf('feat %d, ACC : %.3f\n',featnum,1-err);end

    return;
end
% if nargout>0  %%%dont know happens here????????????
%     return;
% end


%
% loading gram matrix
%
gramfile = create_gramfilename(splitfile,featnum);
gramtestfile = strrep(gramfile,'_feat','_test_feat');

if ~exist(gramfile) || ~exist(gramtestfile)
    error(['gram matrix ''',gramfile,''' does not exist']);
    %    status = write_gram_matrices(splitfile,featnum);
    %    if ~status, error('failed to write gram matrices'); end
end

fprintf('loading kern matrix...');
load(gramfile,'K');K=double(K);
fprintf('done\n');

cvfile = [preddir,'/cvfile.mat'];

if ~exist(cvfile,'file')
    
    if parallel
	fprintf('PARALLEL PROCESSING!\n');

	% first check if everyhting has been done
	doesExist = false(numel(Cs),1);
	cntr = 0;
	for tmpC=Cs
	    cntr = cntr+1;
	    savefile = strrep(cvfile,'.mat',sprintf('_C%d.mat',tmpC));
	    if exist(savefile,'file'), 
		doesExist(cntr) = true;
		load(savefile,'err');
		tmp_err(cntr,1) = err(end);
		clear err;
	    end
	end
	if all(doesExist)
	    tmp_err = tmp_err + 1e-9 * randn(size(tmp_err));
	    [ignore,ind] = min(tmp_err);
	    bestC = Cs(ind(1));
	    fprintf('best C=%.4g,err=%.4g\n',bestC,tmp_err(ind(1)));
	    save(cvfile,'bestC');
	else
	    savefile = strrep(cvfile,'.mat',sprintf('_C%d.mat',C));
	    if exist(savefile,'file'), return; end
	    cvsplitfile = strrep(cvfile,'.mat','_splits.mat')
	    if ~exist(cvsplitfile,'file')
		[train_ind,test_ind] = create_cvsplit(Ytrain,nFolds);
		save(cvsplitfile,'train_ind','test_ind');
	    else
		load(cvsplitfile,'train_ind','test_ind');
	    end
	    out = zeros(size(K,1),nClasses);
	    for f=1:numel(train_ind) 
		% for restarting possibility
		foldfile = strrep(savefile,'.mat',sprintf('_C%d_fold%d.mat',C,f));
		if exist(foldfile,'file')
		    load(foldfile,'thisOut');
		    out(test_ind{f},:) = thisOut;
		else
		    % train 1-vs-rest for all splits
		    out(test_ind{f},:) = one_versus_rest(Ytrain,K,C,l1_reg,train_ind{f},test_ind{f});
		    fprintf('fold %d of %d done\n',f,numel(train_ind));
		    thisOut = out(test_ind{f},:);
		    save(foldfile,'thisOut');
		end
	    end
	    out = out + 1e-9 * randn(size(out));
	    [ignore,Ypred] = max(out');
	    %err(find(C==Cs)) = avg_class_err(Ytrain,Ypred);
	    err = avg_class_err(Ytrain,Ypred);
	    assert(~exist(savefile,'file'));
	    save(savefile,'err');
	    return;
	end	
    else
	
	fprintf('NO PARALLEL PROCESSING, doing everyting sequential!\n');

	fprintf('creating 5 splits of the data...');
	[train_ind,test_ind] = create_cvsplit(Ytrain,nFolds);
	fprintf('done\n');

	%
	% Train once using all the data to find optimal C
	%
	fprintf('CV for optimal parameter C...'); 
	tic;
	cntr = 1;
	for C=Cs % parameter to search over
	    
	    out = zeros(size(K,1),nClasses);
	    for f=1:numel(train_ind) 

		% train 1-vs-rest for all splits

		out(test_ind{f},:) = one_versus_rest(Ytrain,K,C,l1_reg,train_ind{f},test_ind{f});
	    end
	    out = out + 1e-9 * randn(size(out));
	    [ignore,Ypred] = max(out');
	    
	    err(cntr) = avg_class_err(Ytrain,Ypred);
	    cntr = cntr + 1;
	    fprintf('\n%d of %d done (C=%g)\n',cntr,numel(Cs),C);
	end
	t=toc;
	fprintf('done\n');

	err = err + 1e-9 * randn(size(err));
	[ignore,ind] = min(err);

	bestC = Cs(ind(1));
	fprintf('best C=%.4g,err=%.4g time used: %.2g\n',bestC,err(ind(1)),t/60);
	save(cvfile,'bestC');
    end
else    
    load(cvfile,'bestC');
end
fprintf('best C=%.4g\n',bestC);


%
% and now the final classifier
%
fprintf('\n\ntraining final classifier...');
out = zeros(numel(Ytrain),nClasses);
[out,svm_alpha,svm_b] = one_versus_rest(Ytrain,K,bestC,l1_reg,1:numel(Ytrain),1:numel(Ytrain));
out = out + 1e-9*randn(size(out));
[ignore,Ypred] = max(out');
err = avg_class_err(Ytrain,Ypred);
fprintf('training error: %.4f...',err);
fprintf('done\n');

%
% Now the individual classifier
%
fprintf('\n\ntraining on folds for MCLP...');
out = zeros(numel(Ytrain),nClasses);
for f=1:numel(split.train_ind)
    out(split.test_ind{f},:) = one_versus_rest(Ytrain,K,bestC,l1_reg,split.train_ind{f},split.test_ind{f});
end
assert(sum(out(:)==0)==0);
[ignore,Ypred] = max(out');
err = avg_class_err(Ytrain,Ypred);
fprintf('CV error: %.4f...',err);
fprintf('done\n');


%
% write out the predictions for MCLP training
%
fprintf('\n\nwriting out CV predictions for MCLP...');
if numel(tr_files) ~= size(out,1), error('dim mismatch'); end
for i=1:numel(tr_files)
    fname = [preddir,tr_files{i},'.txt'];
    indx=strfind(fname,'/'); indx= indx(end);
    classdir = fname(1:indx);
    if ~exist(classdir,'dir'),system(['mkdir -p ',classdir]);end
    dlmwrite(fname,out(i,:),' ');
end
fprintf('done\n');



%
% PREDICT ON TEST IMAGES
%
load(gramtestfile,'K');K=double(K);
out = zeros(size(K,1),nClasses);
for c=1:nClasses
    out(:,c) = K*svm_alpha{c} + svm_b{c};
end
out = out +1e-9*randn(size(out));
[ignore,Ypred_test] = max(out');
err_test = avg_class_err(Ytest,Ypred_test);
fprintf('Test error: %.4f...',err_test);
fprintf('done\n');


fprintf('\n\nwriting out test predictions for MCLP...');
if numel(te_files) ~= size(out,1), error('dim mismatch'); end
for i=1:numel(te_files)
    fname = [preddir,te_files{i},'.txt'];
    dlmwrite(fname,out(i,:),' ');
end
fprintf('done\n');

save(done_file,'Ypred_test','svm_alpha','svm_b','bestC');
