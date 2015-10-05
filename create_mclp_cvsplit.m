% create the cross validation split for MCLP training. Only split
% the training data of the fold
%
%
function create_mclp_cvsplit(splitfile)

nFolds = 5;
fname = strrep(splitfile,'.mat','_cvsplit.mat');
if exist(fname,'file'), continue; end

load(splitfile,'tr_label')

[a,b] = create_cvsplit(tr_label,nFolds);

split.train_ind = a;
split.test_ind = b;

save(fname,'split');


