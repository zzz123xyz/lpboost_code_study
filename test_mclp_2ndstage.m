% test_mclp_2ndstage(splitfile,combnum,task_sharing)
%
% Compute test predictions using the input parameters. If the
% predictions are already done, simply print out the results
%
% weight_sharing = 1 : LP-beta
% weight_sharing = 0 : LP-B
%
%
% Peter Gehler
function [err,ypred,te_label] = test_mclp_2ndstage(splitfile,combnum,weight_sharing)
err = Inf;
VERBOSE = 0;

load_combinations;
featnums = combination{combnum};

%
% creating directory to write predictions in 
%
str = strrep(strrep(splitfile,'splits/',''),'.mat','');
preddir = ['/scratch_net/biwidl07/projects/caltech/mclp_score/'];
preddir = [preddir,str,'/'];

%
% create this file after everything is done
%
if weight_sharing
    done_file = [preddir,'done_combination',num2str(combnum),'_2ndstage_lpbeta.mat'];	  
else
    done_file = [preddir,'done_combination',num2str(combnum),'_2ndstage_lpB.mat'];	  
end

% check whether the first stage (the bestNU) was already
% computed. If not we can not proceed
if ~exist(done_file,'file'),  return; end

if weight_sharing==0
    predfile = [preddir,'combination',num2str(combnum),'/test_prediction_lpB.mat'];	  
else
    predfile = [preddir,'combination',num2str(combnum),'/test_prediction_lpbeta.mat'];	  
end

load(splitfile,'te_label','te_files');

%
% If this combination was already computed simplty write out the results
%
if exist(predfile,'file')
    load(predfile,'ypred');
    
    if VERBOSE, fprintf('was already computed...reloading\n'); end
    err = avg_class_err(te_label,ypred);
    if VERBOSE
	if weight_sharing==1,fprintf('%d LP-beta    acc %.3f\n',combnum,1-err);
	else,fprintf('%d LP-B    acc %.3f\n',combnum,1-err);  end
    end
    return;
end


%
% TEST: load the result and compute test predictions
%
str = strrep(strrep(splitfile,'splits/',''),'.mat','');
combdir = ['/scratch_net/biwidl07/projects/caltech/mclp_score/',str];
combdir = [combdir,'/combination',num2str(combnum)];

outfile = [combdir,'/2ndstage_',num2str(weight_sharing),'.txt'];
if ~exist(outfile)
    fprintf('final combination not yet done');
    return;
end
A = bzdlmread(outfile); A(A<1e-4) = 0;
if weight_sharing, fprintf('A = ');fprintf('%f ',A);
else, fprintf('mean(A) = ');fprintf('%f ',mean(A));end

fprintf('\nreading in scores...');

%
% read in scores (only those with positive weight)
%
for fn=1:numel(featnums)
    if weight_sharing
	if A(fn)>0
	    t = load_mclp_score(splitfile,te_files,featnums(fn));
	    if ~exist('score','var'), score = zeros(size(t,1),size(t,2),numel(featnums));end
	    score(:,:,fn) = t;
	    fprintf('\n%d of %d features read\n',fn,numel(featnums));
	end
    else
	score(:,:,fn) = load_mclp_score(splitfile,te_files,featnums(fn));
	fprintf('\n%d of %d features read\n',fn,numel(featnums));
    end
end
fprintf('done\n');

fprintf('predicting...');

ypred = mclp_predict(score,A');
err = avg_class_err(te_label,ypred);

fprintf('done\n');

if VERBOSE
    if weight_sharing==1,fprintf('LP-beta acc %.3f\n',1-err);
    else,fprintf('LP-B acc %.3f\n',1-err);end
end

save(predfile,'ypred');
