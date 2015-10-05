% Give a splitfile and some features. This method will cross
% validate over the several features and present the best one.
%
% scores were already computed using train_and_predict.m
function bestFeature = cv_between_features(splitfile,featnums)

[fname,fname_short] = create_fname(splitfile,featnums);
if exist(fname,'file')
    load(fname,'bestFeature');
    return;
end

if exist(fname_short,'file')
    load(fname_short,'bestFeature');
    return;
end


[a,s] = system(['touch ',fname]);
if a~=0, fname = fname_short; end

[a,s] = system(['touch ',fname]);
if a~=0, error('can not create file'); end

system(['rm ',fname]);
fname
load(splitfile,'tr_label','tr_files');

% training data
Ytrain = tr_label;

cntr = 0;
for featnum=featnums
    cntr = cntr + 1;
    clear f;
    load_features;
    fprintf('processing ''%s''\n',explain_feature(f{featnum}));
    clear f;

    score = load_mclp_score(splitfile,tr_files,featnum);
    score = score + 1e-9* randn(size(score));
    [ignore,Ypred] = max(score,[],2);

    err(featnum) = avg_class_err(Ytrain,Ypred);

    fprintf('\n%d of %d done (CV-err: %.4f)\n',cntr,numel(featnums),err(featnum));
end

[ignore,bestFeatureIndx] = (min(err(featnums)));

bestFeature = featnums(bestFeatureIndx);
fprintf('the best feature is number %d\n',bestFeature);

save(fname,'bestFeature');




function [fname,fname_short] = create_fname(splitfile,featnums)
str = 'cv-best';
for ff=featnums
    str = sprintf('%s_f%d',str,ff);
end
fname = sprintf('%s/%s.mat',strrep(strrep(splitfile,'.mat',''),'splits/','mclp_score/'),str);

str = 'cv-best';
for ff=mod(featnums,100)
    str = sprintf('%sf%d',str,ff);
end
fname_short = sprintf('%s/%s.mat',strrep(strrep(splitfile,'.mat',''),'splits/','mclp_score/'),str);
