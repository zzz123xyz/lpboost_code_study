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
function [err,ypred,te_label] = test_mclp_2ndstage_avg(splitfile,combnum);
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

predfile = [preddir,'combination',num2str(combnum),'/test_prediction_avg.mat'];	  

load(splitfile,'te_label','te_files');

%
% If this combination was already computed simplty write out the results
%
if exist(predfile,'file')
    load(predfile,'ypred');
    
    if VERBOSE, fprintf('was already computed...reloading\n'); end
    err = avg_class_err(te_label,ypred);
    if VERBOSE, fprintf('%d: LP-avg    acc %.3f\n',combnum,1-err);end
    return;
end


%
% read in scores (only those with positive weight)
%
score = 0;
fprintf('\nreading in scores...');
for fn=1:numel(featnums)
    try 
	thisScore = load_mclp_score(splitfile,te_files,featnums(fn));
	score = score + thisScore;
    catch
	fprintf('not yet computed\n'); 
	return;
    end
    fprintf('\n%d of %d features read\n',fn,numel(featnums));
end
fprintf('done\n');

fprintf('predicting...');

ypred = mclp_predict(score,1);
err = avg_class_err(te_label,ypred);

fprintf('done\n');
fprintf('avg acc %.3f\n',1-err);


save(predfile,'ypred');
